import faker from 'faker';
import { Pool, PoolClient } from 'pg';

import {
  createClient,
  createPhoneNumber,
  createSendingAccount,
  createSendingLocation,
} from '../__tests__/fixtures';
import {
  fakeNumber,
  findJob,
  setClientIdConfig,
} from '../__tests__/numbers/utils';
import config from '../config';
import { withClient } from '../lib/db';
import { outbound_messages_routing } from '../lib/db-types';
import { ProcessMessagePayload } from '../lib/process-message';
import { Service, TrafficChannel } from '../lib/types';
import {
  process10DlcMessage,
  PROCESS_10DLC_MESSAGE_IDENTIFIER,
} from './process-10dlc-message';

const setUpProcessMessage = async (client: PoolClient, fromNumber: string) => {
  const sendingAccount = await createSendingAccount(client, {
    triggers: true,
    service: Service.Bandwidth,
  });

  const { clientId } = await createClient(client, {});

  const sendingLocation = await createSendingLocation(client, {
    center: '10001',
    triggers: true,
    profile: {
      type: 'create',
      channel: TrafficChannel.TenDlc,
      triggers: true,
      client: { type: 'existing', id: clientId },
      sending_account: { type: 'existing', id: sendingAccount.id },
      profile_service_configuration: {
        type: 'create',
        profile_service_configuration_id: faker.random.uuid(),
      },
      tenDlcCampaign: {},
    },
  });

  await createPhoneNumber(client, {
    sending_location_id: sendingLocation.id,
    phone_number: fromNumber,
  });

  await setClientIdConfig(client, clientId);

  return {
    sendingAccountId: sendingAccount.id,
    profileId: sendingLocation.profile_id,
    sendingLocationId: sendingLocation.id,
  };
};

describe('process message', () => {
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('it should queue a job that processes the message and returns the processed message', async () => {
    const fromNumber = fakeNumber('877');
    const toNumber = fakeNumber();

    const m = await withClient(pool, async (client) => {
      const { profileId } = await setUpProcessMessage(client, fromNumber);

      // insert message to process
      const {
        rows: [message],
      } = await client.query(
        'select id from sms.send_message($1, $2, $3, $4, $5)',
        [profileId, toNumber, faker.hacker.phrase(), null, '11238']
      );

      const foundProcessMessageJob = await findJob<ProcessMessagePayload>(
        client,
        PROCESS_10DLC_MESSAGE_IDENTIFIER,
        'id',
        message.id
      );

      // run process message
      await process10DlcMessage(client, foundProcessMessageJob.payload);

      const {
        rows: [result],
      } = await client.query<outbound_messages_routing>(
        `select * from sms.outbound_messages_routing where id = $1`,
        [message.id]
      );

      return result;
    });

    expect(m.stage).toBe('queued');
    expect(m.sending_location_id).not.toBeNull();
    expect(m.from_number).toBe(fromNumber);
  });

  test('it should carry a requested send_after through to outbound_messages_routing', async () => {
    const fromNumber = fakeNumber('877');
    const toNumber = fakeNumber();
    const sendAfter = new Date(Date.now() + 60 * 60 * 1000);

    const m = await withClient(pool, async (client) => {
      const { profileId } = await setUpProcessMessage(client, fromNumber);

      const {
        rows: [message],
      } = await client.query(
        'select id from sms.send_message($1, $2, $3, $4, $5, $6, $7)',
        [
          profileId,
          toNumber,
          faker.hacker.phrase(),
          null,
          '11238',
          null,
          sendAfter,
        ]
      );

      const foundProcessMessageJob = await findJob<ProcessMessagePayload>(
        client,
        PROCESS_10DLC_MESSAGE_IDENTIFIER,
        'id',
        message.id
      );

      await process10DlcMessage(client, foundProcessMessageJob.payload);

      const {
        rows: [result],
      } = await client.query<outbound_messages_routing>(
        `select * from sms.outbound_messages_routing where id = $1`,
        [message.id]
      );

      return result;
    });

    expect(m.send_after?.getTime()).toBe(sendAfter.getTime());
  });
});
