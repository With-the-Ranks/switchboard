import bodyParser from 'body-parser';
// tslint:disable-next-line: no-var-requires
require('body-parser-xml')(bodyParser);
import connectDatadogGraphql from 'connect-datadog-graphql';
import cors from 'cors';
import express from 'express';

import admin from './apis/admin';
import bandwidth from './apis/bandwidth';
import deliveryReports from './apis/delivery-reports';
import lookup from './apis/graphql/lookup';
import sms from './apis/graphql/sms';
import lookupJson from './apis/lookup-json';
import replies from './apis/replies';
import routing from './apis/routing';
import { expressErrorLogger, expressLogger, statsd } from './logger';

const app = express();

app.use(cors());
app.use(
  (bodyParser as any).xml({
    xmlParseOptions: {
      normalize: true,
      normalizeTags: true,
      explicitArray: false,
    },
  })
);
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(expressLogger);

// Datadog
if (statsd) {
  const datadogOptions = {
    dogstatsd: statsd,
    graphql_paths: ['/lookup/graphql', '/sms/graphql'],
    method: false,
    path: true,
    response_code: true,
  };

  app.use(connectDatadogGraphql(datadogOptions));
}

/**
 * Health check
 */
app.get('/', (_req, res) => res.sendStatus(200));

/**
 * For simple single use lookups
 */
app.use('/lookup/json', lookupJson);

/**
 * For phone number routing (without sending a text)
 */
app.use('/routing', routing);

/**
 * Postgraphile endpoints
 */
app.use('/lookup', lookup);
app.use('/sms', sms);

/**
 * For receiving webhooks
 */
app.use('/hooks/reply', replies);
app.use('/hooks/status', deliveryReports);
app.use('/hooks/bandwidth', bandwidth);

/**
 * For automated admin usage
 */
app.use('/admin', admin);

/**
 * Log errors after all routing
 */
app.use(expressErrorLogger);

export default app;
