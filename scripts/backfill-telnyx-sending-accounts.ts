import { Pool, PoolClient } from 'pg';
import telnyx from 'telnyx';
import * as yargs from 'yargs';

import { setUpProfile } from '../src/apis/admin';
import config from '../src/config';
import { crypt } from '../src/lib/crypt';
import { SendingAccount } from '../src/lib/types';
import { logger } from '../src/logger';

type TransactionHandler<T> = (client: PoolClient) => Promise<T>;
interface SwitchboardProfile {
  id: string;
  client_id: string;
  sending_account_id: string;
  display_name: string;
  reply_webhook_url: string;
  message_status_webhook_url: string;
}

const argv = yargs
  .option('template-sending-account-id', {
    alias: 's',
    description:
      'The ID of the Switchboard sending account to use as a template for new sending accounts',
    type: 'string',
  })
  .help().argv as yargs.Arguments<{ 'template-sending-account-id'?: string }>;
const templateAccountId = argv['template-sending-account-id'];

const pool = new Pool({ connectionString: config.databaseUrl });

const withinTransaction =
  <T>(handler: TransactionHandler<T>) =>
  async () => {
    const client = await pool.connect();
    await client.query('begin');
    try {
      const result = await handler(client);
      await client.query('commit');
      return result;
    } catch (err) {
      await client.query('rollback');
    } finally {
      await client.release();
    }
  };

const portProfile = async (
  sendingAccount: SendingAccount,
  profile: SwitchboardProfile,
  client: PoolClient
) => {
  logger.info(
    `Creating new Telnyx profile for ${profile.display_name} (${profile.id})`
  );

  const { telnyx_credentials } = sendingAccount;
  if (!telnyx_credentials) {
    throw new Error(
      `Received falsey telnyx_credentials for sending account ${sendingAccount.sending_account_id}`
    );
  }

  // Create new sms.sending_accounts record
  const {
    rows: [{ id: newSendingAccountId }],
  } = await client.query(
    `
      insert into sms.sending_accounts (display_name, service)
      values ($1, $2) returning id
    `,
    [profile.display_name, sendingAccount.service]
  );

  // Create the Telnyx profile
  const newTelnyxProfile = await setUpProfile({
    baseAccount: sendingAccount,
    newAccount: {
      profileName: profile.display_name,
      sendingAccountId: newSendingAccountId,
    },
  });

  // Update the sms.sending_accounts record with the new Telnyx profile ID
  await client.query(
    `
      update sms.sending_accounts
      set telnyx_credentials = ($1, $2, $3)
      where id = $4
    `,
    [
      telnyx_credentials.public_key,
      telnyx_credentials.encrypted_api_key,
      newTelnyxProfile.id,
      newSendingAccountId,
    ]
  );

  // Update the Switchboard profile with the new sms.sending_accounts record ID
  await client.query(
    `
      update sms.profiles
      set sending_account_id = $1
      where id = $2
    `,
    [newSendingAccountId, profile.id]
  );

  // Move all phone numbers associated with
  const numbersResult = await client.query(
    `
      select phone_number
      from sms.all_phone_numbers
      where
        sending_location_id in (
          select id from
          sms.sending_locations
          where profile_id = $1
        )
        and released_at is null
        and sold_at is null
        and cordoned_at is null
    `,
    [profile.id]
  );
  const phoneNumbers: string[] = numbersResult.rows.map(
    ({ phone_number }) => phone_number
  );

  logger.info(`Phones to convert: ${phoneNumbers.length}`);

  const apiKey = crypt.decrypt(telnyx_credentials.encrypted_api_key);
  const telnyxClient = telnyx(apiKey);
  await Promise.all(
    phoneNumbers.map(async (phoneNumber) => {
      const result = await telnyxClient.messagingPhoneNumbers.update(
        phoneNumber,
        {
          messaging_profile_id: newTelnyxProfile.id,
        }
      );
    })
  );
};

const main = withinTransaction(async (client) => {
  const sendingAccountResult = await client.query(
    `
      select
        id as sending_account_id,
        service,
        to_json(twilio_credentials) as twilio_credentials,
        to_json(telnyx_credentials) as telnyx_credentials
      from sms.sending_accounts
      where id = $1
    `,
    [templateAccountId]
  );
  const sendingAccount: SendingAccount = sendingAccountResult.rows[0];

  if (!sendingAccount) {
    throw new Error(
      `Could not find sending account with id ${templateAccountId}`
    );
  }

  if (sendingAccount.service !== 'telnyx') {
    throw new Error(
      `Sending account ${templateAccountId} is not a Telnyx account!`
    );
  }

  const profilesResult = await client.query(
    `
      select
        id,
        display_name,
        reply_webhook_url,
        message_status_webhook_url
      from sms.profiles
      where sending_account_id = $1
      order by display_name
      limit 1
    `,
    [templateAccountId]
  );
  const profilesToConvert: SwitchboardProfile[] = profilesResult.rows;

  if (profilesToConvert.length < 1) {
    throw new Error(
      `Could not find profiles using sending account with id ${templateAccountId}`
    );
  }

  for (const profile of profilesToConvert) {
    await portProfile(sendingAccount, profile, client);
  }
});

main()
  .then(() => process.exit(0))
  .catch((err) => {
    logger.error('Script failed with: ', err);
    process.exit(1);
  });
