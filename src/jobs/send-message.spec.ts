import faker from 'faker';
import { Job } from 'graphile-worker';
import RedisMock from 'ioredis-mock';
import { Pool, PoolClient } from 'pg';

import {
  createClient,
  createPhoneNumber,
  createSendingAccount,
  createSendingLocation,
} from '../__tests__/fixtures';
import {
  autoRollbackMiddleware,
  withPgMiddlewares,
} from '../__tests__/helpers';
import { BandwidthNock, TelnyxNock, TwilioNock } from '../__tests__/nocks';
import {
  fakeNumber,
  findGraphileWorkerJob,
  findGraphileWorkerJobs,
  findJob,
  findJobs,
  setClientIdConfig,
} from '../__tests__/numbers/utils';
import config from '../config';
import { ProcessMessagePayload } from '../lib/process-message';
import { defineCustomRedisCommands } from '../lib/redis';
import { RedisClient } from '../lib/redis/redis-index';
import {
  DeliveryReportEvent,
  Service,
  SwitchboardErrorCodes,
} from '../lib/types';
import {
  ASSOCIATE_SERVICE_PROFILE_TO_PHONE_NUMBER_IDENTIFIER,
  AssociateServiceProfileToNumberPayloadSchema,
} from './associate-service-profile-to-phone-number';
import { FORWARD_DELIVERY_REPORT_IDENTIFIER } from './forward-delivery-report';
import {
  PROCESS_GREY_ROUTE_MESSAGE_IDENTIFIER,
  processGreyRouteMessage,
} from './process-grey-route-message';
import {
  SEND_MESSAGE_IDENTIFIER,
  sendMessage,
  SendMessagePayload,
} from './send-message';

const sendAndProcessMessage = async (
  client: PoolClient,
  profileId: string,
  toNumber: string,
  body: string,
  mediaUrls: string[] | null,
  zip: string,
  sendBefore: Date | null,
  sendAfter: Date | null = null
) => {
  const {
    rows: [toProcess],
  } = await client.query(
    `select * from sms.send_message($1, $2, $3, $4, $5, $6, $7)`,
    [profileId, toNumber, body, mediaUrls, zip, sendBefore, sendAfter]
  );

  const foundJob = await findJob(
    client,
    PROCESS_GREY_ROUTE_MESSAGE_IDENTIFIER,
    'id',
    toProcess.id
  );

  const mockRedis = defineCustomRedisCommands(new RedisMock()) as RedisClient;

  const message = await processGreyRouteMessage(
    client,
    foundJob.payload as ProcessMessagePayload,
    mockRedis
  );

  return message;
};

const setupMMSJob = async (client: PoolClient, mediaUrls: string[]) => {
  const myNumber = fakeNumber();

  const messageId = await setupSendMessage(
    client,
    Service.Telnyx,
    myNumber,
    new Date(),
    mediaUrls
  );

  const sendMessageJob = await findGraphileWorkerJob(
    client,
    SEND_MESSAGE_IDENTIFIER,
    'id',
    messageId
  );

  return sendMessageJob;
};

const setupSendMessage = async (
  client: PoolClient,
  service: Service,
  myNumber: string,
  sendBefore: Date | null = null,
  mediaUrls: string[] | null = null,
  sendAfter: Date | null = null
): Promise<string> => {
  const sendingAccount = await createSendingAccount(client, {
    triggers: true,
    service,
  });

  const { clientId } = await createClient(client, {});

  const sendingLocation = await createSendingLocation(client, {
    center: '11238',
    triggers: true,
    profile: {
      type: 'create',
      triggers: true,
      client: { type: 'existing', id: clientId },
      sending_account: { type: 'existing', id: sendingAccount.id },
      profile_service_configuration: {
        type: 'create',
        profile_service_configuration_id: faker.random.uuid(),
      },
    },
  });

  await createPhoneNumber(client, {
    sending_location_id: sendingLocation.id,
    phone_number: myNumber,
  });

  await setClientIdConfig(client, clientId);

  const profileId = sendingLocation.profile_id;

  const message = await sendAndProcessMessage(
    client,
    profileId,
    fakeNumber(),
    faker.hacker.phrase(),
    mediaUrls,
    '11238',
    sendBefore,
    sendAfter
  );

  return message.id;
};

describe('twilio - send message', () => {
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('should sent a request to twilios api and record service id', async () => {
    const twilioId = faker.random.alphaNumeric(8);
    const numSegments = faker.random.number({ max: 5, precision: 1 });
    const costInCents = faker.random.number({ max: 1, precision: 2 });

    const updatedMessage = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const myNumber = fakeNumber();

        const messageId = await setupSendMessage(
          client,
          Service.Twilio,
          myNumber
        );

        const queuedJob = await findJob(
          client,
          SEND_MESSAGE_IDENTIFIER,
          'id',
          messageId
        );

        TwilioNock.createMessage({
          costInCents,
          numSegments,
          code: '200',
          twilioSid: twilioId,
        });

        await sendMessage(client, queuedJob.payload as SendMessagePayload);

        const { rows } = await client.query(
          'select * from sms.outbound_messages_telco where service_id = $1',
          [twilioId]
        );

        return rows[0];
      }
    );

    expect(updatedMessage.num_segments).toEqual(numSegments);
    expect(updatedMessage.service_id).toEqual(twilioId);
    expect(parseFloat(updatedMessage.cost_in_cents)).toEqual(costInCents);
  });

  test('should handle a twilio error 21610 - Attempt to send to unsubscribed recipient response', async () => {
    const testResults = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const myNumber = fakeNumber();

        const messageId = await setupSendMessage(
          client,
          Service.Twilio,
          myNumber
        );

        const sendMessageJob = await findJob(
          client,
          SEND_MESSAGE_IDENTIFIER,
          'id',
          messageId
        );

        TwilioNock.createMessage({ code: '21610' });

        await sendMessage(client, sendMessageJob.payload as SendMessagePayload);

        const {
          rows: [deliveryReportRecord],
        } = await client.query(
          'select * from sms.delivery_reports where message_id = $1',
          [messageId]
        );

        const deliveryReportJob = await findGraphileWorkerJob(
          client,
          FORWARD_DELIVERY_REPORT_IDENTIFIER,
          'message_id',
          messageId
        );

        return [deliveryReportRecord, deliveryReportJob];
      }
    );

    const [deliveryReport, forwardDeliveryReportJob] = testResults;

    expect(deliveryReport.event_type).toEqual(
      DeliveryReportEvent.DeliveryFailed
    );
    expect(deliveryReport.error_codes).toContain(
      SwitchboardErrorCodes.Blacklist
    );
    expect(forwardDeliveryReportJob).not.toBeUndefined();
    expect(forwardDeliveryReportJob.payload.event_type).toEqual(
      DeliveryReportEvent.DeliveryFailed
    );
  });
});

describe('telnyx - send message', () => {
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('should send a request to telnyxs api and record service id', async () => {
    const telnyxUuid = faker.random.uuid();
    const numSegments = faker.random.number({ max: 5, precision: 1 });

    const testResults = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const myNumber = fakeNumber();

        const messageId = await setupSendMessage(
          client,
          Service.Telnyx,
          myNumber
        );

        const queuedJob = await findJob(
          client,
          SEND_MESSAGE_IDENTIFIER,
          'id',
          messageId
        );

        TelnyxNock.createMessage({
          numSegments,
          code: '200',
          serviceId: telnyxUuid,
        });

        await sendMessage(client, queuedJob.payload as SendMessagePayload);

        const {
          rows: [updatedMessageRecord],
        } = await client.query(
          'select * from sms.outbound_messages_telco where service_id = $1',
          [telnyxUuid]
        );

        return updatedMessageRecord;
      }
    );

    const updatedMessage = testResults;

    expect(updatedMessage.num_segments).toEqual(numSegments);
    expect(updatedMessage.service_id).toEqual(telnyxUuid);
  });

  test('should handle a telnyx error 40300 - Blocked due to STOP message response', async () => {
    const testResults = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const myNumber = fakeNumber();

        const messageId = await setupSendMessage(
          client,
          Service.Telnyx,
          myNumber
        );

        const sendMessageJob = await findJob(
          client,
          SEND_MESSAGE_IDENTIFIER,
          'id',
          messageId
        );

        TelnyxNock.createMessage({ code: '40300' });

        await sendMessage(client, sendMessageJob.payload as SendMessagePayload);

        const {
          rows: [deliveryReportRecord],
        } = await client.query(
          'select * from sms.delivery_reports where message_id = $1',
          [messageId]
        );

        const deliveryReportJob = await findGraphileWorkerJob(
          client,
          FORWARD_DELIVERY_REPORT_IDENTIFIER,
          'message_id',
          messageId
        );

        return [deliveryReportRecord, deliveryReportJob];
      }
    );

    const [deliveryReport, forwardDeliveryReportJob] = testResults;

    expect(deliveryReport.event_type).toEqual(
      DeliveryReportEvent.DeliveryFailed
    );
    expect(deliveryReport.error_codes).toContain(
      SwitchboardErrorCodes.Blacklist
    );
    expect(forwardDeliveryReportJob).not.toBeUndefined();
    expect(forwardDeliveryReportJob.payload.event_type).toEqual(
      DeliveryReportEvent.DeliveryFailed
    );
  });

  test('should error for an unexpected telnyx error response', async () => {
    await withPgMiddlewares(pool, [autoRollbackMiddleware], async (client) => {
      const myNumber = fakeNumber();

      const messageId = await setupSendMessage(
        client,
        Service.Telnyx,
        myNumber
      );

      const sendMessageJob = await findJob(
        client,
        SEND_MESSAGE_IDENTIFIER,
        'id',
        messageId
      );

      TelnyxNock.createMessage({ code: '40006' });

      const payload = sendMessageJob.payload as SendMessagePayload;
      const jobPromise = sendMessage(client, payload);
      await expect(jobPromise).rejects.toThrowError(
        'Recipient server unavailable'
      );
    });
  });

  test('should re-associate messaging profile for "invalid from number" error', async () => {
    await withPgMiddlewares(pool, [autoRollbackMiddleware], async (client) => {
      const myNumber = fakeNumber();
      const sendingAccount = await createSendingAccount(client, {
        triggers: true,
        service: Service.Telnyx,
      });

      const { clientId } = await createClient(client, {});

      const sendingLocation = await createSendingLocation(client, {
        center: '11238',
        triggers: true,
        profile: {
          type: 'create',
          triggers: true,
          client: { type: 'existing', id: clientId },
          sending_account: { type: 'existing', id: sendingAccount.id },
          profile_service_configuration: {
            type: 'create',
            profile_service_configuration_id: faker.random.uuid(),
          },
        },
      });

      await createPhoneNumber(client, {
        sending_location_id: sendingLocation.id,
        phone_number: myNumber,
      });

      await setClientIdConfig(client, clientId);

      await Promise.all(
        [...Array(2)].map(() =>
          sendAndProcessMessage(
            client,
            sendingLocation.profile_id,
            fakeNumber(),
            faker.hacker.phrase(),
            [],
            '11238',
            null
          )
        )
      );

      const sendMessageJobs = await findJobs(
        client,
        SEND_MESSAGE_IDENTIFIER,
        'from_number',
        myNumber
      );

      for (const sendMessageJob of sendMessageJobs) {
        TelnyxNock.createMessage({ code: '40305' });
        const sendMessagePayload = sendMessageJob.payload as SendMessagePayload;
        const jobPromise = sendMessage(client, sendMessagePayload);
        await expect(jobPromise).rejects.toThrowError(
          /^Invalid (telnyx|twilio) from number/
        );
      }

      const associateProfileJobs = await findGraphileWorkerJobs(
        client,
        ASSOCIATE_SERVICE_PROFILE_TO_PHONE_NUMBER_IDENTIFIER,
        'phone_number',
        myNumber
      );

      expect(associateProfileJobs.length).toBe(1);
      const payload = AssociateServiceProfileToNumberPayloadSchema.parse(
        associateProfileJobs[0].payload
      );
      expect(payload.phone_number).toEqual(myNumber);
    });
  });

  test('should insert a fake 30001 if after send_before', async () => {
    const [message, deliveryReport] = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const myNumber = fakeNumber();

        const messageId = await setupSendMessage(
          client,
          Service.Telnyx,
          myNumber,
          new Date()
        );

        const sendMessageJob = await findJob(
          client,
          SEND_MESSAGE_IDENTIFIER,
          'id',
          messageId
        );

        const payload = sendMessageJob.payload as SendMessagePayload;
        await sendMessage(client, payload);

        const {
          rows: [m],
        } = await client.query(
          'select * from sms.outbound_messages_telco where id = $1',
          [messageId]
        );
        const {
          rows: [dr],
        } = await client.query(
          'select * from sms.delivery_reports where message_id = $1',
          [messageId]
        );

        return [m, dr];
      }
    );

    expect(message.telco_status).toBe('failed');
    expect(deliveryReport.error_codes).toEqual(['30001']);
  });
});

describe('bandwidth - send message', () => {
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('should sent a request to bandwidth api and record service id', async () => {
    const serviceId = faker.random.alphaNumeric(29);
    const numSegments = faker.random.number({ max: 5, precision: 1 });

    const updatedMessage = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const myNumber = fakeNumber();

        const messageId = await setupSendMessage(
          client,
          Service.Bandwidth,
          myNumber
        );

        const queuedJob = await findJob(
          client,
          SEND_MESSAGE_IDENTIFIER,
          'id',
          messageId
        );

        BandwidthNock.createMessage({
          serviceId,
          numSegments,
          code: '200',
        });

        await sendMessage(client, queuedJob.payload as SendMessagePayload);

        const { rows } = await client.query(
          'select * from sms.outbound_messages_telco where service_id = $1',
          [serviceId]
        );

        return rows[0];
      }
    );

    expect(updatedMessage.num_segments).toEqual(numSegments);
    expect(updatedMessage.service_id).toEqual(serviceId);
  });
});

describe('send message', () => {
  let pool: Pool;

  beforeAll(() => {
    pool = new Pool({ connectionString: config.databaseUrl });
  });

  afterAll(() => {
    return pool.end();
  });

  test('should not have flags set if no mms', async () => {
    const job = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => {
        const myNumber = fakeNumber();

        const messageId = await setupSendMessage(
          client,
          Service.Telnyx,
          myNumber,
          new Date()
        );

        const sendMessageJob = (await findJob(
          client,
          SEND_MESSAGE_IDENTIFIER,
          'id',
          messageId
        )) as unknown as Job;

        return sendMessageJob;
      }
    );

    expect(job.flags).toBeFalsy();
  });

  test('should have flags set if mms', async () => {
    const job = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) =>
        setupMMSJob(client, [
          'https://i.ytimg.com/vi/2mm9rP8_lUk/hqdefault.jpg',
        ])
    );

    expect(job.flags).toEqual({ 'send-message-mms:global': true });
  });

  test('should have flags set if empty mms', async () => {
    const job = await withPgMiddlewares(
      pool,
      [autoRollbackMiddleware],
      async (client) => setupMMSJob(client, [])
    );

    expect(job.flags).toEqual({ 'send-message-mms:global': true });
  });

  test('should reject send_after that is not before send_before', async () => {
    await withPgMiddlewares(pool, [autoRollbackMiddleware], async (client) => {
      const myNumber = fakeNumber();
      const sendBefore = new Date();
      const sendAfter = new Date(sendBefore.getTime() + 1000 * 60 * 60);

      await expect(
        setupSendMessage(
          client,
          Service.Telnyx,
          myNumber,
          sendBefore,
          null,
          sendAfter
        )
      ).rejects.toThrow(/send_after must be before send_before/);
    });
  });

  test('should reject send_after for a non-10dlc (grey-route) profile', async () => {
    await withPgMiddlewares(pool, [autoRollbackMiddleware], async (client) => {
      const myNumber = fakeNumber();
      const sendAfter = new Date(Date.now() + 1000 * 60 * 60);

      await expect(
        setupSendMessage(
          client,
          Service.Telnyx,
          myNumber,
          null,
          null,
          sendAfter
        )
      ).rejects.toThrow(/send_after is only supported for the 10dlc channel/);
    });
  });
});
