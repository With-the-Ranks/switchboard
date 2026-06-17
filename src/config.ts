import { bool, cleanEnv, CleanEnv, host, num, port, str, url } from 'envalid';

interface AppConfig extends CleanEnv {
  databaseUrl: string;
  ddAgentHost: string;
  ddDogstatsdPort: number;
  ddTags: string[];
  dryRunMode: boolean;
  baseUrl: string;
  logLevel: string;
  minPoolSize: number;
  maxPoolSize: number;
  adminAccessToken: string;
  applicationSecret: string;
  redisUrl: string | undefined;
  telnyxApiKey: string; // For Telnyx v2 api (used for phone number lookups)
  telnyxNumberSearchCount: number;
  twilioAccountSid: string;
  twilioAuthToken: string;
  port: number;
  mode: string;
  workerConcurrency: number;
  minSuitableNumbers: number;
  sendingLocationMinCallingNumbers: number;
  jobsToRun: undefined | string[];
  mmsPerSecond: number;
  mmsSurgeCount: number;
  graphileWorkerConcurrency: number;
  checkOldMessagesForPrevMapping: boolean;
  trackCost: boolean;
  adminActionWebhookUrl: string | undefined;
}

const env = cleanEnv(process.env, {
  ADMIN_ACCESS_TOKEN: str({ default: 'admin' }),
  ADMIN_ACTION_WEBHOOK_URL: url({ default: undefined }),
  APPLICATION_SECRET: str({ default: 'secret' }),
  BASE_URL: url(),
  CHECK_OLD_MESSAGES_FOR_PREV_MAPPING: bool({ default: false }),
  DD_AGENT_HOST: host({ default: undefined }),
  DD_DOGSTATSD_PORT: port({ default: undefined }),
  DD_TAGS: str({ default: 'app:numbers' }),
  DRY_RUN_MODE: bool({
    desc: 'When enabled, run with only simulated requests to telco APIs',
    default: undefined,
  }),
  GRAPHILE_WORKER_CONCURRENCY: num({ default: 100 }),
  JOBS_TO_RUN: str({ default: undefined }),
  LOG_LEVEL: str({
    desc: 'The winston log level.',
    choices: ['silly', 'debug', 'verbose', 'info', 'warn', 'error'],
    default: 'warn',
    devDefault: 'silly',
  }),
  MAX_POOL_SIZE: num({ default: 20, devDefault: 50 }),
  MIN_POOL_SIZE: num({ default: 1 }),
  MIN_SUITABLE_NUMBERS: num({ default: 50 }),
  SENDING_LOCATION_MIN_CALLING_NUMBERS: num({ default: 1 }),
  MMS_PER_SECOND: num({ default: 25 }),
  MMS_SURGE_COUNT: num({ default: 250 }),
  MODE: str({ default: 'DUAL' }),
  PORT: num({ default: 3000 }),
  POSTGRES_URL: url({ default: undefined }),
  PROD_POSTGRES_URL: url({ default: undefined }),
  REDIS_URL: url({ default: undefined }),
  TELNYX_API_KEY: str({ default: undefined }),
  TELNYX_NUMBER_SEARCH_COUNT: num({ default: 500 }),
  TEST_POSTGRES_URL: url({ default: undefined }),
  TRACK_COST: bool({ default: false }),
  TWILIO_ACCOUNT_SID: str({ default: undefined }),
  TWILIO_AUTH_TOKEN: str({ default: undefined }),
  WORKER_CONCURRENCY: num({ default: 100 }),
});

const envConfig = {
  isDev: env.isDev,
  isDevelopment: env.isDevelopment,
  isProd: env.isProduction,
  isProduction: env.isProduction,
  isTest: env.isTest,
};

const config: AppConfig = {
  ...envConfig,
  adminAccessToken: env.ADMIN_ACCESS_TOKEN,
  adminActionWebhookUrl: env.ADMIN_ACTION_WEBHOOK_URL,
  applicationSecret: env.APPLICATION_SECRET,
  baseUrl: env.BASE_URL,
  checkOldMessagesForPrevMapping: env.CHECK_OLD_MESSAGES_FOR_PREV_MAPPING,
  databaseUrl: envConfig.isTest
    ? env.TEST_POSTGRES_URL
    : envConfig.isProduction
    ? env.PROD_POSTGRES_URL
    : env.POSTGRES_URL,
  ddAgentHost: env.DD_AGENT_HOST,
  ddDogstatsdPort: env.DD_DOGSTATSD_PORT,
  ddTags: env.DD_TAGS.split(','),
  dryRunMode: env.DRY_RUN_MODE ?? env.isDev,
  graphileWorkerConcurrency: env.GRAPHILE_WORKER_CONCURRENCY,
  jobsToRun:
    env.JOBS_TO_RUN === undefined ? undefined : env.JOBS_TO_RUN.split(','),
  logLevel: env.LOG_LEVEL,
  maxPoolSize: env.MAX_POOL_SIZE,
  minPoolSize: env.MIN_POOL_SIZE,
  minSuitableNumbers: env.MIN_SUITABLE_NUMBERS,
  sendingLocationMinCallingNumbers: env.SENDING_LOCATION_MIN_CALLING_NUMBERS,
  mmsPerSecond: env.MMS_SURGE_COUNT,
  mmsSurgeCount: env.MMS_SURGE_COUNT,
  mode: env.MODE,
  port: env.PORT,
  redisUrl: env.REDIS_URL,
  telnyxApiKey: env.TELNYX_API_KEY,
  telnyxNumberSearchCount: env.TELNYX_NUMBER_SEARCH_COUNT,
  trackCost: env.TRACK_COST,
  twilioAccountSid: env.TWILIO_ACCOUNT_SID,
  twilioAuthToken: env.TWILIO_AUTH_TOKEN,
  workerConcurrency: env.WORKER_CONCURRENCY,
};

if (config.databaseUrl === undefined) {
  process.stdout.write('Missing valid database url environment variable\n');
  process.exit(1);
}

export default config;
