import faker from 'faker';
import { Pool, PoolClient } from 'pg';

import {
  autoRollbackMiddleware,
  withPgMiddlewares,
} from '../__tests__/helpers';
import { TwilioNock } from '../__tests__/nocks';
import { findJob } from '../__tests__/numbers/utils';
import config from '../config';

import {
  createSendingAccount,
  createSendingLocation,
} from '../__tests__/fixtures';
import { SendingLocationPurchasingStrategy, Service } from '../lib/types';
import { logger } from '../logger';
import {
  FIND_SUITABLE_AREA_CODES_IDENTIFIER,
  findSuitableAreaCodes,
  FindSuitableAreaCodesPayload,
} from './find-suitable-area-codes';

const setUpFindSuitableAreaCodes = async (
  client: PoolClient
): Promise<{ sendingAccountId: string; sendingLocationId: string }> => {
  const sendingAccount = await createSendingAccount(client, {
    triggers: true,
    service: Service.Twilio,
  });

  const sendingLocation = await createSendingLocation(client, {
    center: '10001',
    purchasing_strategy: SendingLocationPurchasingStrategy.SameStateByDistance,
    triggers: true,
    profile: {
      type: 'create',
      triggers: true,
      client: { type: 'create' },
      sending_account: { type: 'existing', id: sendingAccount.id },
      profile_service_configuration: {
        type: 'create',
        profile_service_configuration_id: faker.random.uuid(),
      },
    },
  });

  return {
    sendingAccountId: sendingAccount.id,
    sendingLocationId: sendingLocation.id,
  };
};

describe('find suitable area codes', () => {
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('should find suitable area codes', async () => {
    const [availablePhoneNumbersCount, modifiedSendingLocation] =
      await withPgMiddlewares(
        pool,
        [autoRollbackMiddleware],
        async (client) => {
          const { sendingLocationId } = await setUpFindSuitableAreaCodes(
            client
          );

          const job = await findJob(
            client,
            FIND_SUITABLE_AREA_CODES_IDENTIFIER,
            'id',
            sendingLocationId
          );

          // set up nocks
          // nock responses to the first and third area codes it would search
          // for so that it skips the second
          TwilioNock.getNumberAvailability(1, 30);
          TwilioNock.getNumberAvailability(1, 0);
          TwilioNock.getNumberAvailability(1, 30);

          await findSuitableAreaCodes(
            client,
            job.payload as FindSuitableAreaCodesPayload
          );

          const {
            rows: [sendingLocation],
          } = await client.query(
            'select * from sms.sending_locations where id = $1',
            [sendingLocationId]
          );

          const {
            rows: [{ count }],
          } = await client.query(
            'select sms.compute_sending_location_capacity($1) as count',
            [sendingLocationId]
          );

          return [count, sendingLocation];
        }
      );

    expect(availablePhoneNumbersCount).toBeGreaterThanOrEqual(50);
    expect(modifiedSendingLocation.area_codes).toEqual('{212,518}'); // skipping 516
  });

  test('should warn if not enough', async () => {
    const spiedLog = jest.spyOn(logger, 'warn');

    await withPgMiddlewares(pool, [autoRollbackMiddleware], async (client) => {
      const { sendingLocationId } = await setUpFindSuitableAreaCodes(client);

      const job = await findJob(
        client,
        FIND_SUITABLE_AREA_CODES_IDENTIFIER,
        'id',
        sendingLocationId
      );

      // set up nocks
      // nock responses so that it doesn't find enough (8 NY + 1 NJ = 9 total)
      TwilioNock.getNumberAvailability(9, 0);

      await findSuitableAreaCodes(
        client,
        job.payload as FindSuitableAreaCodesPayload
      );
    });

    expect(spiedLog).toHaveBeenCalled();
  });

  test('should move to another state after exhausted in the current one', async () => {
    const modifiedSendingLocation = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId } = await setUpFindSuitableAreaCodes(client);

        const job = await findJob(
          client,
          FIND_SUITABLE_AREA_CODES_IDENTIFIER,
          'id',
          sendingLocationId
        );

        // we have 8 NY area codes (212,516,518,646,718,917 at dist 0, then 347,914 via zip 10012), 1 NJ one
        // nock responses so that it doesn't find enough in NY
        TwilioNock.getNumberAvailability(8, 0);
        // and finds enough in NJ
        TwilioNock.getNumberAvailability(1, 100);

        await findSuitableAreaCodes(
          client,
          job.payload as FindSuitableAreaCodesPayload
        );

        const {
          rows: [sendingLocation],
        } = await client.query(
          'select * from sms.sending_locations where id = $1',
          [sendingLocationId]
        );

        return sendingLocation;
      }
    );

    // expect the sending location to use the one area code
    // in NJ despite having an NY center, because we've mocked
    // the NY ones to be empty
    expect(modifiedSendingLocation.area_codes).toEqual('{609}'); // only NJ code in dev seed (08540/Princeton)
  });
});
