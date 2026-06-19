import faker from 'faker';
import RedisMock from 'ioredis-mock';
import flatten from 'lodash/flatten';
import reverse from 'lodash/reverse';
import sortBy from 'lodash/sortBy';
import { Pool, PoolClient } from 'pg';

import config from '../../config';
import {
  NOTICE_SENDING_LOCATION_CHANGE_IDENTIFIER,
  noticeSendingLocationChange,
} from '../../jobs/notice-sending-location-change';
import {
  PROCESS_GREY_ROUTE_MESSAGE_IDENTIFIER,
  processGreyRouteMessage,
} from '../../jobs/process-grey-route-message';
import {
  RESOLVE_MESSAGES_AWAITING_FROM_NUMBER_IDENTIFIER,
  resolveMessagesAwaitingFromNumber,
} from '../../jobs/resolve-messages-awaiting-from-number';
import { SEND_MESSAGE_IDENTIFIER } from '../../jobs/send-message';
import {
  number_purchasing_strategy,
  sending_locations,
} from '../../lib/db-types';
import { SwitchboardEmitter } from '../../lib/emitter';
import { insert } from '../../lib/inserter';
import { ProcessMessagePayload } from '../../lib/process-message';
import { defineCustomRedisCommands } from '../../lib/redis/index';
import {
  RedisClient,
  resetAllHydrationState,
} from '../../lib/redis/redis-index';
import { Service } from '../../lib/types';
import { nowAsDate } from '../../lib/utils';
import {
  createClient,
  createProfile,
  createSendingLocation,
} from '../fixtures';
import { autoRollbackMiddleware, withPgMiddlewares } from '../helpers';
import {
  fakeNumber,
  findGraphileWorkerJob,
  findJob,
  setClientIdConfig,
} from './utils';

jest.mock('../../lib/utils', () => ({
  nowAsDate: jest.fn(() => {
    const d = new Date();
    return d;
  }),
}));

// test the check constraints
// test the uniqueness constraint on name client

const n = () => faker.random.number({ min: 0, max: 9, precision: 1 });

const setUpProfile = async (client: PoolClient) => {
  const { id: profileId } = await createProfile(client, {
    triggers: true,
    client: { type: 'create' },
    sending_account: {
      type: 'create',
      triggers: true,
      service: Service.Telnyx,
    },
    profile_service_configuration: {
      type: 'create',
      profile_service_configuration_id: faker.random.uuid(),
    },
  });

  return profileId;
};

const setUpSendingLocation = async (client: PoolClient, center: string) => {
  const { clientId } = await createClient(client, {});

  const { id: sendingLocationId, profile_id: profileId } =
    await createSendingLocation(client, {
      center,
      triggers: true,
      profile: {
        type: 'create',
        triggers: true,
        client: { type: 'existing', id: clientId },
        sending_account: {
          type: 'create',
          triggers: true,
          service: Service.Telnyx,
        },
        profile_service_configuration: {
          type: 'create',
          profile_service_configuration_id: faker.random.uuid(),
        },
      },
    });

  return { sendingLocationId, clientId, profileId };
};

const insertDummyMessage = async (
  client: PoolClient,
  message: {
    sendingLocationId: string;
    profileId: string;
    fromNumber: string;
    zipCode?: string;
    stage?: string;
  }
) =>
  client
    .query<{ id: string; to_number: string; created_at: string }>(
      `
        insert into sms.outbound_messages (contact_zip_code, stage, to_number, body, profile_id)
        values ($1, $2, $3, $4, $5)
        returning id, to_number, created_at
      `,
      [
        message.zipCode || '11238',
        message.stage || 'sent',
        fakeNumber(),
        faker.hacker.phrase(),
        message.profileId,
      ]
    )
    .then(({ rows: [row] }) => row)
    .then(({ id, to_number, created_at }) =>
      client.query(
        `
          insert into sms.outbound_messages_routing (id, original_created_at, sending_location_id, to_number, from_number, stage, profile_id)
          values ($1, $2, $3, $4, $5, $6, $7)
        `,
        [
          id,
          created_at,
          message.sendingLocationId,
          to_number,
          message.fromNumber,
          message.stage || 'sent',
          message.profileId,
        ]
      )
    );

// To test with real redis, comment out the line below and uncomment the line after
// Testing with mockRedis is fine, but we should occasionally test with real redis
// as well to catch potential bugs in ioredis-mock
const mockRedis = defineCustomRedisCommands(new RedisMock()) as RedisClient;
// const mockRedis = getRedis();

const doSendAndProcessMessage = async (
  client: PoolClient,
  sendMessageParams: [
    string, // profile_id
    string, // to
    string, // body
    string | null, // media_urls
    string // contact_zip_code
  ]
): Promise<any> => {
  const {
    rows: [message],
  } = await client.query(
    `select * from sms.send_message($1, $2, $3, $4, $5)`,
    sendMessageParams
  );

  const foundJob = await findJob<ProcessMessagePayload>(
    client,
    PROCESS_GREY_ROUTE_MESSAGE_IDENTIFIER,
    'id',
    message.id
  );

  const result = await processGreyRouteMessage(
    client,
    foundJob.payload as ProcessMessagePayload,
    mockRedis
  );

  return result;
};

describe('psql helpers', () => {
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('sms.extract_area_code', async () => {
    const {
      rows: [{ extract_area_code: areaCode }],
    } = await withPgMiddlewares(pool, [], async (client) => {
      return client.query('select sms.extract_area_code($1)', ['+12147010869']);
    });
    expect(areaCode).toBe('214');
  });

  test('sms.map_area_code_to_zip_code', async () => {
    const {
      rows: [{ map_area_code_to_zip_code: zipCode }],
    } = await withPgMiddlewares(pool, [], async (client) => {
      return client.query(
        'select sms.map_area_code_to_zip_code(sms.extract_area_code($1))',
        ['+12127010869']
      );
    });
    expect(zipCode).toBe('10001');
  });

  test('sms.sending_locations before insert should find area codes and queue capacity searches', async () => {
    const areaCodes = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const profileId = await setUpProfile(client);
        const {
          rows: [{ area_codes: codes }],
        } = await client.query(
          'insert into sms.sending_locations (profile_id, reference_name, center) values ($1, $2, $3) returning area_codes',
          [profileId, 'test', '11373']
        );

        return codes.replace('{', '').replace('}', '').split(',');
      }
    );

    expect(areaCodes).toEqual(
      expect.arrayContaining(['646', '917', '718', '347'])
    );
  });

  test('sms.choose_area_code_for_sending_location should choose max', async () => {
    const codeBreakdowns = [
      ['646', n()],
      ['917', n()],
      ['718', n()],
      ['347', n()],
    ];

    const chosenAreaCode = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const profileId = await setUpProfile(client);

        const {
          rows: [{ sending_account_id: sendingAccountId }],
        } = await client.query('select * from sms.profiles where id = $1', [
          profileId,
        ]);

        const {
          rows: [{ id: sendingLocationId }],
        } = await client.query(
          'insert into sms.sending_locations (profile_id, reference_name, center) values ($1, $2, $3) returning id',
          [profileId, 'test', '11373']
        );

        await client.query(
          'insert into sms.area_code_capacities (area_code, capacity, sending_account_id) values ($1, $2, $9), ($3, $4, $9), ($5, $6, $9), ($7, $8, $9)',
          flatten(codeBreakdowns).concat([sendingAccountId])
        );

        const {
          rows: [{ choose_area_code_for_sending_location: areaCode }],
        } = await client.query(
          'select sms.choose_area_code_for_sending_location($1)',
          [sendingLocationId]
        );

        return areaCode;
      }
    );

    const maxOfCodeBreakdowns = reverse(
      sortBy(codeBreakdowns, ([code, count]) => `${count}|${code}`)
    )[0][0];
    expect(chosenAreaCode).toEqual(maxOfCodeBreakdowns);
  });

  test('sms.choose_sending_location_for_contact should choose same state', async () => {
    const [toChooseSendingLocationId, chosenSendingLocationId] =
      await withPgMiddlewares(
        pool,
        [autoRollbackMiddleware],
        async (client) => {
          const profileId = await setUpProfile(client);

          const {
            rows: [{ id: toChoose }],
          } = await client.query(
            'insert into sms.sending_locations (profile_id, reference_name, center) values ($1, $2, $3) returning id',
            [profileId, 'less_close_ny', '11373']
          );

          await client.query(
            'insert into sms.sending_locations (profile_id, reference_name, center) values ($1, $2, $3) returning id',
            [profileId, 'closer_nj', '07030']
          );

          const {
            rows: [{ choose_sending_location_for_contact: chosen }],
          } = await client.query(
            'select sms.choose_sending_location_for_contact($1, $2)',
            ['11238', profileId]
          );

          const { rows: toLog } = await client.query(
            'select * from sms.sending_locations'
          );

          return [toChoose, chosen];
        }
      );

    expect(toChooseSendingLocationId).toEqual(chosenSendingLocationId);
  });

  test('sms.choose_sending_location_for_contact should choose closest if no state match', async () => {
    const [toChooseSendingLocationId, chosenSendingLocationId] =
      await withPgMiddlewares(
        pool,
        [autoRollbackMiddleware],
        async (client) => {
          const profileId = await setUpProfile(client);

          const {
            rows: [{ id: toChoose }],
          } = await client.query(
            'insert into sms.sending_locations (profile_id, reference_name, center) values ($1, $2, $3) returning id',
            [profileId, 'closer_nj', '07030']
          );

          await client.query(
            'insert into sms.sending_locations (profile_id, reference_name, center) values ($1, $2, $3) returning id',
            [profileId, 'less_close_nj', '08540']
          );

          const {
            rows: [{ choose_sending_location_for_contact: chosen }],
          } = await client.query(
            'select sms.choose_sending_location_for_contact($1, $2)',
            ['11238', profileId]
          );

          return [toChoose, chosen];
        }
      );

    expect(toChooseSendingLocationId).toEqual(chosenSendingLocationId);
  });
});

describe('sms.send_message', () => {
  let pool: Pool;

  beforeAll(async () => {
    await resetAllHydrationState(mockRedis);
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('should use mapping of previous number', async () => {
    const [shouldChoose, chosen] = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId, clientId, profileId } =
          await setUpSendingLocation(client, '11238');
        const toNumber = fakeNumber();
        const fromNumber = fakeNumber();

        const { rows } = await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2) returning *',
          [fromNumber, sendingLocationId]
        );

        // Create previous mapping
        const [messageId, createdAt] = await client
          .query<{ id: string; created_at: string }>(
            `
              insert into sms.outbound_messages (contact_zip_code, stage, to_number, body)
              values ($1, $2, $3, $4)
              returning id, created_at
            `,
            ['11238', 'sent', toNumber, faker.hacker.phrase()]
          )
          .then(({ rows: [{ id, created_at }] }) => [id, created_at]);

        await client.query(
          'insert into sms.outbound_messages_routing (id, original_created_at, sending_location_id, stage, to_number, from_number, profile_id, decision_stage) values ($1, $2, $3, $4, $5, $6, $7, $8)',
          [
            messageId,
            createdAt,
            sendingLocationId,
            'sent',
            toNumber,
            fromNumber,
            profileId,
            'existing_phone_number',
          ]
        );

        await setClientIdConfig(client, clientId);

        const message = await doSendAndProcessMessage(client, [
          profileId,
          toNumber,
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        return [fromNumber, message.from_number];
      }
    );

    expect(shouldChoose).toEqual(chosen);
  });

  test('hydration: should choose existing number with available capacity', async () => {
    const [shouldChoose, chosen] = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId, clientId, profileId } =
          await setUpSendingLocation(client, '11238');
        const toNumber = fakeNumber();
        const fromNumber = fakeNumber();

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
          [fromNumber, sendingLocationId]
        );

        await setClientIdConfig(client, clientId);

        const message = await doSendAndProcessMessage(client, [
          profileId,
          toNumber,
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        return [fromNumber, message.from_number];
      }
    );

    expect(shouldChoose).toEqual(chosen);
  });

  test('online: should choose new number with available capacity', async () => {
    const [shouldChoose, chosen] = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId, clientId, profileId } =
          await setUpSendingLocation(client, '11238');
        const fromNumber = fakeNumber();
        const fromNumber2 = fakeNumber();

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
          [fromNumber, sendingLocationId]
        );

        await setClientIdConfig(client, clientId);

        await doSendAndProcessMessage(client, [
          profileId,
          fakeNumber(),
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
          [fromNumber2, sendingLocationId]
        );

        SwitchboardEmitter.emit(profileId, 'fulfilled:phone_number_request', {
          sending_location_id: sendingLocationId,
          phone_number: fromNumber2,
          id: faker.random.uuid(),
          area_code: '914',
        });

        const secondMessage = await doSendAndProcessMessage(client, [
          profileId,
          fakeNumber(),
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        return [secondMessage.from_number, fromNumber2];
      }
    );

    expect(shouldChoose).toEqual(chosen);
  });

  test('online: should skip overloaded numbers', async () => {
    // In this test, we set it up so that number A has sent to 100 people today, but none in the last minute
    // number B has sent to only 6 today, but all in the last minute
    // We expect to choose number A

    const a = fakeNumber();
    const b = fakeNumber();

    // Using a static to number for the final process makes debugging easier
    const finalToNumber = '+15557010869';

    const chosen = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId, clientId, profileId } =
          await setUpSendingLocation(client, '11238');

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
          [a, sendingLocationId]
        );

        await setClientIdConfig(client, clientId);

        const iteration = 0;
        // tslint:disable-next-line: prefer-array-literal
        for (const _ of [...new Array(100)]) {
          const toNumber = fakeNumber();
          await doSendAndProcessMessage(client, [
            profileId,
            toNumber,
            faker.hacker.phrase(),
            null,
            '11238',
          ]);
        }

        await client.query(
          `update sms.outbound_messages_routing set processed_at = processed_at - '1 minute'::interval`
        );

        // resets the overloaded status of A
        await resetAllHydrationState(mockRedis);

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
          [b, sendingLocationId]
        );

        // tslint:disable-next-line: prefer-array-literal
        for (const _ of [...new Array(7)]) {
          await doSendAndProcessMessage(client, [
            profileId,
            fakeNumber(),
            faker.hacker.phrase(),
            null,
            '11238',
          ]);
        }

        const final = await doSendAndProcessMessage(client, [
          profileId,
          finalToNumber,
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        return final.from_number;
      }
    );

    expect(chosen).toEqual(a);
  });

  test('online: should route to overloaded numbers after a minute', async () => {
    // In this test, we set it up so that number A has sent to 100 people today, but none in the last minute
    // number B has sent to 7 one minute ago
    // We expect to choose number B because the minute has passed

    const a = fakeNumber();
    const b = fakeNumber();

    // Using a static to number for the final process makes debugging easier
    const finalToNumber = '+15557010869';

    const chosen = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId, clientId, profileId } =
          await setUpSendingLocation(client, '11238');

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
          [a, sendingLocationId]
        );

        await setClientIdConfig(client, clientId);

        // tslint:disable-next-line: prefer-array-literal
        const startingAt = new Date();
        startingAt.setHours(startingAt.getHours() - 2);

        // tslint:disable-next-line: prefer-array-literal
        for (const _ of new Array(10).fill(null)) {
          const toNumber = fakeNumber();

          // mock now to be several hours ago, so this is sending over 2 hours
          (nowAsDate as any).mockImplementation(() => {
            startingAt.setMinutes(startingAt.getMinutes() + 1);
            return new Date(startingAt.getTime());
          });

          const result = await doSendAndProcessMessage(client, [
            profileId,
            toNumber,
            faker.hacker.phrase(),
            null,
            '11238',
          ]);
        }

        // resets the overloaded status of A
        await resetAllHydrationState(mockRedis);

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
          [b, sendingLocationId]
        );

        // mock now to be now again
        (nowAsDate as any).mockImplementation(() => {
          const d = new Date();
          return d;
        });

        // tslint:disable-next-line: prefer-array-literal
        for (const _ of new Array(6).fill(null)) {
          await doSendAndProcessMessage(client, [
            profileId,
            fakeNumber(),
            faker.hacker.phrase(),
            null,
            '11238',
          ]);
        }

        const final = await doSendAndProcessMessage(client, [
          profileId,
          finalToNumber,
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        return final.from_number;
      }
    );

    expect(chosen).toEqual(b);
  });

  test('online: should know about new sending locations', async () => {
    const [firstSendingLocationId, secondSendingLocationId] =
      await withPgMiddlewares(
        pool,
        [autoRollbackMiddleware],
        async (client) => {
          const { sendingLocationId, clientId, profileId } =
            await setUpSendingLocation(client, '11238');
          const fromNumber = fakeNumber();
          const fromNumber2 = fakeNumber();

          await client.query(
            'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
            [fromNumber, sendingLocationId]
          );

          await setClientIdConfig(client, clientId);

          await doSendAndProcessMessage(client, [
            profileId,
            fakeNumber(),
            faker.hacker.phrase(),
            null,
            '90210',
          ]);

          const secondSendingLocation = await insert(
            client,
            'sending_locations',
            {
              profile_id: profileId,
              center: '10004',
              reference_name: 'test',
              purchasing_strategy:
                number_purchasing_strategy.SameStateByDistance,
            }
          );

          await client.query(
            'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
            [fromNumber2, secondSendingLocation.id]
          );

          const noticeJob = await findJob<sending_locations>(
            client,
            NOTICE_SENDING_LOCATION_CHANGE_IDENTIFIER,
            'id',
            secondSendingLocation.id
          );

          await noticeSendingLocationChange(client, noticeJob.payload);

          const secondMessage = await doSendAndProcessMessage(client, [
            profileId,
            fakeNumber(),
            faker.hacker.phrase(),
            null,
            '10004',
          ]);

          return [sendingLocationId, secondMessage.sending_location_id];
        }
      );

    expect(firstSendingLocationId).not.toEqual(secondSendingLocationId);
  });

  test('hydration: should map to existing number request if over capacity and one exists', async () => {
    const [shouldChoose, chosen] = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId, clientId, profileId } =
          await setUpSendingLocation(client, '11238');
        const toNumber = fakeNumber();
        const overCapacityFromNumber = fakeNumber();

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
          [overCapacityFromNumber, sendingLocationId]
        );

        await setClientIdConfig(client, clientId);

        // tslint:disable-next-line: prefer-array-literal
        for (const _i of new Array(250).fill(null)) {
          await insertDummyMessage(client, {
            sendingLocationId,
            profileId,
            fromNumber: overCapacityFromNumber,
          });
        }

        const {
          rows: [{ id: pendingNumberRequestId }],
        } = await client.query(
          'insert into sms.phone_number_requests (sending_location_id, area_code) values ($1, $2) returning id',
          [sendingLocationId, '917']
        );

        const routing = await doSendAndProcessMessage(client, [
          profileId,
          toNumber,
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        return [pendingNumberRequestId, routing.pending_number_request_id];
      }
    );

    expect(shouldChoose).toEqual(chosen);
  });

  test('hydration: should create new number request', async () => {
    const pendingNumberRequestId = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId, clientId, profileId } =
          await setUpSendingLocation(client, '11238');
        const toNumber = fakeNumber();
        const overCapacityFromNumber = fakeNumber();

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
          [overCapacityFromNumber, sendingLocationId]
        );

        await setClientIdConfig(client, clientId);

        // tslint:disable-next-line: prefer-array-literal
        for (const _i of new Array(250).fill(null)) {
          await insertDummyMessage(client, {
            sendingLocationId,
            profileId,
            fromNumber: overCapacityFromNumber,
          });
        }

        const message = await doSendAndProcessMessage(client, [
          profileId,
          toNumber,
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        return message.pending_number_request_id;
      }
    );

    expect(pendingNumberRequestId).toBeTruthy();
  });

  test(
    'online: should be notified about new number requests with proper zincrby',
    async () => {
      const [createdPendingRequest, routedPendingRequest] =
        await withPgMiddlewares(
          pool,
          [autoRollbackMiddleware],
          async (client) => {
            const { sendingLocationId, clientId, profileId } =
              await setUpSendingLocation(client, '11238');
            const toNumber = fakeNumber();
            const overCapacityFromNumber = fakeNumber();

            await client.query(
              'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
              [overCapacityFromNumber, sendingLocationId]
            );

            await setClientIdConfig(client, clientId);

            // tslint:disable-next-line: prefer-array-literal
            for (const _i of new Array(250).fill(null)) {
              await doSendAndProcessMessage(client, [
                profileId,
                fakeNumber(),
                faker.hacker.phrase(),
                null,
                '11238',
              ]);
            }

            const phoneNumberRequest = await insert(
              client,
              'phone_number_requests',
              {
                sending_location_id: sendingLocationId,
                area_code: '914',
              },
              profileId
            );

            const message = await doSendAndProcessMessage(client, [
              profileId,
              toNumber,
              faker.hacker.phrase(),
              null,
              '11238',
            ]);

            return [phoneNumberRequest.id, message.pending_number_request_id];
          }
        );

      expect(createdPendingRequest).toEqual(routedPendingRequest);
    },
    10 * 1000
  );
});

describe('sms.send_message - cordoning', () => {
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('should not use mapping of previous number if cordoned 4 days ago', async () => {
    const [shouldChoose, chosen] = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId, clientId, profileId } =
          await setUpSendingLocation(client, '11238');
        const toNumber = fakeNumber();
        const fromNumber = fakeNumber();

        const sixDaysAgo = new Date();
        sixDaysAgo.setDate(sixDaysAgo.getDate() - 6);

        const { rows } = await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id, cordoned_at) values ($1, $2, $3) returning *',
          [fromNumber, sendingLocationId, sixDaysAgo]
        );

        await client.query(
          'insert into sms.outbound_messages (contact_zip_code, stage, to_number, body) values ($1, $2, $3, $4)',
          ['11238', 'sent', toNumber, faker.hacker.phrase()]
        );

        await setClientIdConfig(client, clientId);

        const message = await doSendAndProcessMessage(client, [
          profileId,
          toNumber,
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        return [fromNumber, message.from_number];
      }
    );

    expect(shouldChoose).not.toEqual(chosen);
  });

  test('should not choose existing number with available capacity if cordoned recently', async () => {
    const [shouldChoose, chosen] = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId, clientId, profileId } =
          await setUpSendingLocation(client, '11238');
        const toNumber = fakeNumber();
        const fromNumber = fakeNumber();

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id, cordoned_at) values ($1, $2, $3)',
          [fromNumber, sendingLocationId, new Date()]
        );

        await setClientIdConfig(client, clientId);

        const message = await doSendAndProcessMessage(client, [
          profileId,
          toNumber,
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        return [fromNumber, message.from_number];
      }
    );

    expect(shouldChoose).not.toEqual(chosen);
  });
});

describe('sms.tg__phone_number_requests__fulfill', () => {
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('should queue messages that were awaiting the request', async () => {
    const countToSend = 10;
    // insert profile, sending location, call send message a few times, fulfill the pending request, the messages should be queued
    const [sentCount, purchasedCount, sentWithSendAfterCount] =
      await withPgMiddlewares(
        pool,
        [autoRollbackMiddleware],
        async (client) => {
          const { sendingLocationId, clientId, profileId } =
            await setUpSendingLocation(client, '11238');

          await setClientIdConfig(client, clientId);

          // tslint:disable-next-line: prefer-array-literal
          for (const _i of new Array(countToSend).fill(null)) {
            await doSendAndProcessMessage(client, [
              profileId,
              fakeNumber(),
              faker.hacker.phrase(),
              null,
              '11238',
            ]);
          }

          const { rows: pendingNumberRequests } = await client.query(
            'select * from sms.phone_number_requests where for_calling = false and sending_location_id = $1',
            [sendingLocationId]
          );

          expect(pendingNumberRequests).toHaveLength(1);

          const [pendingNumberRequest] = pendingNumberRequests;

          expect(pendingNumberRequest.sending_location_id).toEqual(
            sendingLocationId
          );

          const areaCode = pendingNumberRequest.area_code;
          const fakeFullfilledNumber = `+1${areaCode}${n()}${n()}${n()}${n()}${n()}${n()}${n()}`;

          await client.query(
            'update sms.phone_number_requests set fulfilled_at = now(), phone_number = $1 where id = $2',
            [fakeFullfilledNumber, pendingNumberRequest.id]
          );

          const foundJob = await findGraphileWorkerJob(
            client,
            RESOLVE_MESSAGES_AWAITING_FROM_NUMBER_IDENTIFIER,
            'id',
            pendingNumberRequest.id
          );

          await resolveMessagesAwaitingFromNumber(client, foundJob.payload);

          const {
            rows: [{ count: countNumbers }],
          } = await client.query('select count(*) from sms.phone_numbers');
          const {
            rows: [{ count: countQueued }],
          } = await client.query(
            'select count(*) from sms.outbound_messages_routing where stage = $1',
            ['queued']
          );

          const {
            rows: [{ count: countQueuedWithSendAfter }],
          } = await client.query(
            'select count(*) from sms.outbound_messages_routing where stage = $1 and send_after is not null',
            ['queued']
          );

          return [
            parseInt(countQueued, 10),
            parseInt(countNumbers, 10),
            parseInt(countQueuedWithSendAfter, 10),
          ];
        }
      );

    expect(countToSend).toEqual(sentCount);
    expect(sentWithSendAfterCount).toEqual(sentCount);
    expect(purchasedCount).toBe(1);
  });
});

describe('trigger_job_with_sending_account_info', () => {
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('should queue a job with sending_account info', async () => {
    const queuedJob = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const { sendingLocationId, clientId, profileId } =
          await setUpSendingLocation(client, '11238');
        const toNumber = fakeNumber();
        const fromNumber = fakeNumber();

        await client.query(
          'insert into sms.phone_numbers (phone_number, sending_location_id) values ($1, $2)',
          [fromNumber, sendingLocationId]
        );

        await client.query(
          'insert into sms.outbound_messages (contact_zip_code, stage, to_number, body) values ($1, $2, $3, $4)',
          ['11238', 'sent', toNumber, faker.hacker.phrase()]
        );

        await setClientIdConfig(client, clientId);

        const message = await doSendAndProcessMessage(client, [
          profileId,
          toNumber,
          faker.hacker.phrase(),
          null,
          '11238',
        ]);

        const foundJob = await findJob(
          client,
          SEND_MESSAGE_IDENTIFIER,
          'id',
          message.id
        );

        return foundJob;
      }
    );

    expect(queuedJob.payload).toHaveProperty('service');
    expect(queuedJob.payload).toHaveProperty('twilio_credentials');
    expect(queuedJob.payload).toHaveProperty('telnyx_credentials');
  });
});
