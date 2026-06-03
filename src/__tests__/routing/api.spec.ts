import faker from 'faker';
import { Pool } from 'pg';
import supertest from 'supertest';

import app from '../../app';
import config from '../../config';
import { withClient } from '../../lib/db';
import { Service } from '../../lib/types';
import {
  createPhoneNumber,
  createProfile,
  createSendingAccount,
  createSendingLocation,
} from '../fixtures';

describe('GET /routing/get-number-for-contact', () => {
  let pool: Pool;
  let accessToken: string;

  let toNumberWithMapping: string;
  let expectedFromNumber: string;

  let profileIdWithMapping: string;
  let profileIdWithSendingLocation: string;
  let profileIdNoSendingLocations: string;

  beforeAll(async () => {
    pool = new Pool({ connectionString: config.databaseUrl });

    const registerResponse = await supertest(app)
      .post('/admin/register')
      .set('token', config.adminAccessToken)
      .send({ name: `routing-api-test-${faker.random.uuid()}` });
    accessToken = registerResponse.body.access_token;

    await withClient(pool, async (client) => {
      // Profile with an existing from_number mapping
      const sa1 = await createSendingAccount(client, {
        service: Service.Telnyx,
        triggers: true,
      });
      const sl1 = await createSendingLocation(client, {
        center: '10001',
        triggers: true,
        profile: {
          type: 'create',
          triggers: true,
          client: { type: 'create' },
          sending_account: { type: 'existing', id: sa1.id },
          profile_service_configuration: {
            type: 'create',
            profile_service_configuration_id: `MS${faker.random.alphaNumeric(
              30
            )}`,
          },
        },
      });
      profileIdWithMapping = sl1.profile_id;
      toNumberWithMapping = faker.phone.phoneNumber('+1##########');
      expectedFromNumber = faker.phone.phoneNumber('+1##########');
      await client.query(
        `INSERT INTO sms.from_number_mappings
           (profile_id, to_number, from_number, last_used_at, sending_location_id)
         VALUES ($1, $2, $3, now(), $4)`,
        [profileIdWithMapping, toNumberWithMapping, expectedFromNumber, sl1.id]
      );

      // Profile with a sending location and phone number (new-contact happy path)
      const sa2 = await createSendingAccount(client, {
        service: Service.Telnyx,
        triggers: true,
      });
      const sl2 = await createSendingLocation(client, {
        center: '10001',
        triggers: true,
        profile: {
          type: 'create',
          triggers: true,
          client: { type: 'create' },
          sending_account: { type: 'existing', id: sa2.id },
          profile_service_configuration: {
            type: 'create',
            profile_service_configuration_id: `MS${faker.random.alphaNumeric(
              30
            )}`,
          },
        },
      });
      profileIdWithSendingLocation = sl2.profile_id;
      await createPhoneNumber(client, { sending_location_id: sl2.id });

      // Profile with no sending locations (404 path)
      const sa3 = await createSendingAccount(client, {
        service: Service.Telnyx,
        triggers: true,
      });
      const emptyProfile = await createProfile(client, {
        triggers: true,
        client: { type: 'create' },
        sending_account: { type: 'existing', id: sa3.id },
        profile_service_configuration: {
          type: 'create',
          profile_service_configuration_id: `MS${faker.random.alphaNumeric(
            30
          )}`,
        },
      });
      profileIdNoSendingLocations = emptyProfile.id;
    });
  });

  afterAll(() => pool.end());

  test('returns 401 without an auth token', async () => {
    const response = await supertest(app)
      .get('/routing/get-number-for-contact')
      .query({
        to_number: '+12125551234',
        profile_id: faker.random.uuid(),
        contact_zip_code: '10001',
      });

    expect(response.status).toBe(401);
  });

  test('returns 400 when required query params are missing', async () => {
    const response = await supertest(app)
      .get('/routing/get-number-for-contact')
      .set('token', accessToken)
      .query({ to_number: '+12125551234' });

    expect(response.status).toBe(400);
    expect(response.body.error).toContain('required');
  });

  test('returns the existing from_number when a mapping already exists', async () => {
    const response = await supertest(app)
      .get('/routing/get-number-for-contact')
      .set('token', accessToken)
      .query({
        to_number: toNumberWithMapping,
        profile_id: profileIdWithMapping,
        contact_zip_code: '10001',
      });

    expect(response.status).toBe(200);
    expect(response.body.from_number).toBe(expectedFromNumber);
  });

  test('returns 404 when no sending location exists for the profile', async () => {
    const response = await supertest(app)
      .get('/routing/get-number-for-contact')
      .set('token', accessToken)
      .query({
        to_number: faker.phone.phoneNumber('+1##########'),
        profile_id: profileIdNoSendingLocations,
        contact_zip_code: '10001',
      });

    expect(response.status).toBe(404);
    expect(response.body.error).toBe('No sending location found for contact');
  });

  test('returns a from_number for a new contact via sending location', async () => {
    const response = await supertest(app)
      .get('/routing/get-number-for-contact')
      .set('token', accessToken)
      .query({
        to_number: faker.phone.phoneNumber('+1##########'),
        profile_id: profileIdWithSendingLocation,
        contact_zip_code: '10001',
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('from_number');
    expect(typeof response.body.from_number).toBe('string');
  });

  test('returns a from_number when contact_zip_code is omitted, using area code from to_number', async () => {
    const response = await supertest(app)
      .get('/routing/get-number-for-contact')
      .set('token', accessToken)
      .query({
        to_number: faker.phone.phoneNumber('+1212#######'),
        profile_id: profileIdWithSendingLocation,
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('from_number');
    expect(typeof response.body.from_number).toBe('string');
  });
});
