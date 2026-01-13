import {
  CampaignService,
  OpenAPI,
  PhoneNumberCampaignsService,
} from '@rewired/telnyx-10dlc';
import telnyx from 'telnyx';
import config from '../../config';
import { crypt } from '../../lib/crypt';
import {
  BadNumberStatusError,
  CodedSendMessageError,
  InvalidFromNumberError,
  NoAvailableNumbersError,
  NoTelnyxNumberOrderCreatedError,
} from '../../lib/errors';
import {
  DeliveryReport,
  IncomingMessage,
  SendingAccount,
  Service,
  SwitchboardErrorCodes,
  TelnyxDeliveryReportRequestBody,
  TelnyxReplyRequestBody,
} from '../../lib/types';
import { errToObj, logger } from '../../logger';
import { PostgresErrorCodes } from '../postgres-errors';
import { sleep } from '../utils';
import {
  Associate10dlcCampaignTnOptions,
  AssociateServiceProfileOptions,
  EstimateAreaCodeCapacityOptions,
  GetMnoMetadataOptions,
  GetMnoMetadataPayload,
  InboundMessageResponseHandler,
  ParseDeliveryReportOptions,
  ParseDeliveryReportPayload,
  ParseInboundMessageOptions,
  ParseInboundMessagePayload,
  PollNumberOrderOptions,
  PurchaseNumberOptions,
  SellNumberOptions,
  SendMessageOptions,
  SendMessagePayload,
  SwitchboardClient,
} from './service';

import superagent from 'superagent';

interface TelnyxOpenAPICombined {
  PhoneNumberCampaignsService: typeof PhoneNumberCampaignsService;
  CampaignService: typeof CampaignService;
}

interface TelnyxPollNumberResponse {
  data: { status: string; phone_numbers: Array<{ phone_number: string }> };
}

interface TelnyxListAvailablePhoneNumbersResponse {
  metadata: { total_results: number };
  data: Array<{ phone_number: string }>;
}

interface TelnyxUpdateMessagingPhoneNumberResponse {
  data: {
    messaging_profile_id: string;
  };
}

interface TelnyxPurchaseNumberResponse {
  data: {
    id: string;
  };
}

export class TelnyxService extends SwitchboardClient {
  protected publicKey: string;
  protected apiKey: string;
  protected v2Client: any;

  constructor(public sendingAccount: SendingAccount) {
    super(sendingAccount);

    const { telnyx_credentials } = sendingAccount;
    if (telnyx_credentials === null) {
      throw new Error(
        `Undefined telnyx credentials for sending account ${sendingAccount.sending_account_id}`
      );
    }
    const { public_key, encrypted_api_key } = telnyx_credentials;

    const apiKey = crypt.decrypt(encrypted_api_key);
    this.publicKey = public_key;
    this.apiKey = apiKey;
    this.v2Client = telnyx(apiKey);
  }

  public async sendMessage(
    options: SendMessageOptions
  ): Promise<SendMessagePayload> {
    const body: any = {
      from: options.from_number,
      text: options.body.replace('–', '-').replace('–', '-'),
      to: options.to_number,
      webhook_url: `${config.baseUrl}/hooks/status/${this._sendingAccount.sending_account_id}`,
    };

    if (
      options.media_urls &&
      Array.isArray(options.media_urls)
      // && options.media_urls.length > 0
      // 2024-01-26 Telnyx can send MMS without attachment
      // https://telnyx.com/products/mms-api
    ) {
      body.media_urls = options.media_urls;
      body.type = 'MMS';
      // 2024-01-26 Need to set type to send MMS with empty media_urls
      // Optional when media_urls is not empty
    }

    try {
      const response = await this.v2Client.messages.create(body);
      const message = response.data;

      return {
        // telnyx cost comes from the delivery report
        costInCents: null,
        extra: { carrier: message.carrier, line_type: message.line_type },
        numMedia: Array.isArray(options.media_urls)
          ? options.media_urls.length
          : 0,
        numSegments: message.parts,
        serviceId: message.id,
      };
    } catch (err: any) {
      // Throw the error if it was not a coded Telnyx response (e.g. network timeout)
      if (!err.raw || !err.raw.errors) throw err;

      const {
        errors: [telnyxError],
      } = err.raw;

      if (telnyxError.code === '40021') {
        throw new CodedSendMessageError(
          SwitchboardErrorCodes.InvalidDestinationNumber
        );
      } else if (telnyxError.code === '40300') {
        throw new CodedSendMessageError(SwitchboardErrorCodes.Blacklist);
      } else if (telnyxError.code === '40322') {
        throw new CodedSendMessageError(SwitchboardErrorCodes.SpamContent);
      } else if (telnyxError.code === '40305') {
        throw new InvalidFromNumberError(Service.Telnyx, options.from_number);
      }

      logger.warn('Encountered unexpected Telnyx error: ', {
        options,
        error: errToObj(err),
      });
      throw err;
    }
  }

  public async purchaseNumber(options: PurchaseNumberOptions): Promise<void> {
    const { area_code: areaCode } = options;

    const attemptTelnyxPurchase = async (
      phoneNumber: string,
      messagingProfileId: string | null
    ) => {
      // TODO - use voice_callback_url (right now configured separately)
      // https://www.notion.so/Support-Telnyx-voice-callback-configuration-14d995e5283f4c2b8d3ebb78639872e0
      const response: TelnyxPurchaseNumberResponse =
        await this.v2Client.numberOrders.create({
          messaging_profile_id: messagingProfileId,
          phone_numbers: [{ phone_number: phoneNumber }],
        });
      const order = response.data;

      if (!order) {
        throw new NoTelnyxNumberOrderCreatedError('telnyx', areaCode);
      }

      return { phoneNumber, orderId: order.id };
    };

    const squashAnticipatedError = (err: any) => {
      if (err.raw) {
        const { statusCode, errors } = err.raw;
        if (statusCode === 400 && errors[0].code === '10015') {
          // The number is no longer available, try the next matchingNumber
          return;
        }
        if (statusCode === 409 && errors[0].code === '85001') {
          // The number is no longer available, try the next matchingNumber
          return;
        }
      }
      if (err.code && err.code === PostgresErrorCodes.UniqueViolation) {
        // Move on to the next number if error is a phone number conflict with another purchase request
        return;
      }

      throw err;
    };

    const matchingNumbers = await this.getTelnyxNumbers(areaCode);

    while (matchingNumbers.length > 0) {
      const phoneNumber = matchingNumbers.pop()!;

      // Make sure a different request didn't just buy this number
      if (await options.doesLivePhoneNumberExist(phoneNumber)) {
        continue;
      }

      try {
        const result = await attemptTelnyxPurchase(
          phoneNumber,
          options.service_profile_id
        );
        await options.saveResult(result);
        return;
      } catch (err) {
        squashAnticipatedError(err);
        continue;
      }
    }

    throw new NoAvailableNumbersError(this._service, areaCode);
  }

  public async estimateAreaCodeCapacity(
    options: EstimateAreaCodeCapacityOptions
  ): Promise<number> {
    const capacity = await this.v2Client.availablePhoneNumbers
      .list({
        filter: {
          best_effort: true,
          country_code: 'US',
          exclude_regulatory_requirements: true,
          features: ['sms'],
          limit: config.telnyxNumberSearchCount,
          national_destination_code: options.areaCode,
        },
      })
      .then(
        ({
          metadata: { total_results },
        }: TelnyxListAvailablePhoneNumbersResponse) => total_results
      )
      .catch((err: any) => {
        if (err.raw) {
          logger.error('Error fetching Telnyx capacity: ', {
            ...errToObj(err.raw),
            areaCode: options.areaCode,
          });
        }
        throw err;
      });

    return capacity;
  }

  public async sellNumber(options: SellNumberOptions): Promise<void> {
    const { phone_number } = options;

    const foundNumber = await this.v2Client.phoneNumbers
      .list({ filter: { phone_number } })
      .then(({ data }: { data: any }) => data[0] as string);

    if (!foundNumber) {
      throw new Error(
        `No phone number matching ${phone_number} was found in this Telnyx account`
      );
    }

    // We can't count on Telnyx actually deleting the number so retry until we know for sure
    for (let attempts = 0; attempts < 5; attempts += 1) {
      try {
        await this.v2Client.phoneNumbers.del(foundNumber.id);
      } catch (err: any) {
        // A 404 response means that the number was successfully deleted on the previous request
        if (err.statusCode === 404) {
          return;
        }

        // Throw any other error
        throw err;
      }

      await sleep(500);
    }

    // Throw error if it takes more than 5 delete attempts
    const message = 'Telnyx sell-number took more than 5 attempts';
    logger.error(message, { phone_number });
    throw new Error(message);
  }

  public async associateServiceProfile(
    options: AssociateServiceProfileOptions
  ): Promise<string> {
    const { phoneNumber, serviceProfileId } = options;

    const { data }: TelnyxUpdateMessagingPhoneNumberResponse =
      await this.v2Client.messagingPhoneNumbers
        .update(phoneNumber, { messaging_profile_id: serviceProfileId })
        .catch((err: unknown) => {
          logger.error(
            `Error updating Telnyx Messaging Profile for ${phoneNumber}: `,
            errToObj(err)
          );
          throw err;
        });

    if (data.messaging_profile_id !== serviceProfileId) {
      const message = `Could not verify messaging profile for purchase of ${phoneNumber}!`;
      logger.error(message, { data });
      throw new Error(message);
    }

    return data.messaging_profile_id;
  }

  public async pollNumberOrder(options: PollNumberOrderOptions): Promise<void> {
    await this.v2Client.numberOrders
      .retrieve(options.serviceOrderId)
      .then(({ data: { status, phone_numbers } }: TelnyxPollNumberResponse) => {
        const { phone_number } = phone_numbers[0];
        if (status !== 'success') {
          return this.pollNumberStatusTelnyx(phone_number);
        }
        return phone_number;
      });
  }

  public async parseDeliveryReport(
    options: ParseDeliveryReportOptions
  ): Promise<ParseDeliveryReportPayload> {
    const { req } = options;

    let event: TelnyxDeliveryReportRequestBody;
    let validated = false;

    try {
      event = this.v2Client.webhooks.constructEvent(
        JSON.stringify(req.body, null, 2),
        req.header('telnyx-signature-ed25519'),
        req.header('telnyx-timestamp'),
        this.publicKey
      );
      validated = true;
    } catch (ex) {
      // TODO – reject bad incoming messages and figure out good test solution
      event = req.body;
    }

    const payload = event.data.payload;

    const costInCents = payload.cost?.amount
      ? parseFloat(payload.cost.amount) * 100
      : null;

    const deliveryReport: DeliveryReport = {
      costInCents,
      validated,
      errorCodes: (payload.errors || []).map((e) => e.code),
      eventType: payload.to[0].status,
      extra: {
        // just to have in case the update on sms.outbound_messages fails because of sequencing issues
        cost: payload.cost,
        // this contains carrier information!
        to: payload.to,
      },
      generatedAt: new Date(payload.completed_at),
      messageServiceId: payload.id,
      service: this._service,
    };

    return { deliveryReport };
  }

  public async processInboundMessage(
    options: ParseInboundMessageOptions
  ): Promise<ParseInboundMessagePayload> {
    const { req } = options;

    let event: TelnyxReplyRequestBody;
    let validated = false;

    try {
      event = this.v2Client.webhooks.constructEvent(
        JSON.stringify(req.body, null, 2),
        req.header('telnyx-signature-ed25519'),
        req.header('telnyx-timestamp'),
        this.publicKey
      );
      validated = true;
    } catch (ex) {
      // TODO – reject bad incoming messages and figure out good test solution
      event = req.body;
    }

    const payload = event.data.payload;

    const to = Array.isArray(payload.to)
      ? payload.to[0].phone_number
      : payload.to;

    const message: IncomingMessage = {
      to,
      validated,
      body: payload.text,
      extra: {
        from_carrier: payload.from.carrier,
      },
      from: payload.from.phone_number,
      mediaUrls: payload.media.map((attachment) => attachment.url),
      numMedia: payload.media.length,
      numSegments: payload.parts,
      receivedAt: payload.received_at,
      service: this._service,
      serviceId: payload.id,
    };

    const httpResponseHandler: InboundMessageResponseHandler = (
      messageId,
      res
    ) => {
      res.set('x-created-message-id', messageId);
      res.sendStatus(200);
    };

    return { message, httpResponseHandler };
  }

  public async associate10dlcCampaignTn(
    options: Associate10dlcCampaignTnOptions
  ): Promise<void> {
    const url = `https://api.telnyx.com/10dlc/phone_number_campaigns`;

    try {
      await superagent
        .post(url)
        .set('Authorization', `Bearer ${this.apiKey}`)
        .send(options);
    } catch (err) {
      logger.error(
        `Error updating Telnyx Messaging Profile for ${options.phoneNumber}: `,
        errToObj(err)
      );
      throw err;
    }
  }

  public async getMnoMetadata({
    campaignId,
  }: GetMnoMetadataOptions): Promise<GetMnoMetadataPayload> {
    const client = this.getOpenApiClient();
    const mnoMetaData =
      await client.CampaignService.getMyCampaignMnoMetadataCampaignCampaignIdMnoMetadataGet(
        campaignId
      ).catch((err: unknown) => {
        logger.error(
          `Error fetching MNO metadata for campaign ${campaignId}: `,
          errToObj(err)
        );
        throw err;
      });

    return mnoMetaData;
  }

  protected getOpenApiClient(): TelnyxOpenAPICombined {
    OpenAPI.TOKEN = this.apiKey;

    return {
      PhoneNumberCampaignsService,
      CampaignService,
    };
  }

  protected async getTelnyxNumbers(areaCode: string) {
    const { data: matchingNumbers }: TelnyxListAvailablePhoneNumbersResponse =
      await this.v2Client.availablePhoneNumbers.list({
        filter: {
          best_effort: true,
          country_code: 'US',
          exclude_regulatory_requirements: true,
          features: ['sms'],
          limit: config.telnyxNumberSearchCount,
          national_destination_code: areaCode,
        },
      });
    return matchingNumbers.map(({ phone_number }) => phone_number) as string[];
  }

  protected async pollNumberStatusTelnyx(phoneNumber: string) {
    const { data } = await this.v2Client.phoneNumbers.list({
      filter: { phone_number: phoneNumber },
    });
    if (data.length !== 1) {
      throw new Error(
        `poll_telnyx_number_status expected 1 result got ${data.length}`
      );
    }
    const numberNumberRecord = data[0];
    if (numberNumberRecord.status !== 'active') {
      throw new BadNumberStatusError(
        this._service,
        phoneNumber,
        numberNumberRecord.status
      );
    }

    return phoneNumber;
  }
}

export default TelnyxService;
