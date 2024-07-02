# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [5.3.0](https://github.com/politics-rewired/switchboard/compare/v5.2.0...v5.3.0) (2024-07-02)


### Features

* add taxable column for billing ([#3](https://github.com/politics-rewired/switchboard/issues/3)) ([8058282](https://github.com/politics-rewired/switchboard/commit/8058282bf0a40fb2234da291b85c6544c2fd8177))


### Backend Changes

* add license ([5f38703](https://github.com/politics-rewired/switchboard/commit/5f38703b27be177b48f4968a9e4b62711f192f3f))

## [5.2.0](https://github.com/politics-rewired/switchboard/compare/v5.1.0...v5.2.0) (2024-03-04)


### Features

* **10dlc:** support multiple numbers per sending location ([#2](https://github.com/politics-rewired/switchboard/issues/2)) ([dd56994](https://github.com/politics-rewired/switchboard/commit/dd5699497685db6be36436a7ef4bed08f264fc3c))

## 5.1.0 (2024-03-02)


### Features

* public commit ([926092f](https://github.com/politics-rewired/switchboard/commit/926092f230cfcabd8da235cc234fe4ab5f4ca5b4))

### [5.0.1](https://github.com/politics-rewired/switchboard/compare/v5.0.0...v5.0.1) (2024-02-07)


### Bug Fixes

* **telnyx:** avoid sdk to associate 10dlc campaign ([#422](https://github.com/politics-rewired/switchboard/issues/422)) ([b9e58b7](https://github.com/politics-rewired/switchboard/commit/b9e58b76f3c0dbd2f72649a1d15adccc7c2e520e))


### Backend Changes

* remove unused telnyx envvar references ([#420](https://github.com/politics-rewired/switchboard/issues/420)) ([492c242](https://github.com/politics-rewired/switchboard/commit/492c24208903dbd9edeb921b79ace23d9e376394))

## [5.0.0](https://github.com/politics-rewired/switchboard/compare/v4.0.3...v5.0.0) (2024-01-31)


### Features

* support sending mms without media ([#418](https://github.com/politics-rewired/switchboard/issues/418)) ([d0f0a9f](https://github.com/politics-rewired/switchboard/commit/d0f0a9f2b93a161e00a787bd80b21910625bf334))


### Bug Fixes

* **update-dump:** add cap add flag ([#419](https://github.com/politics-rewired/switchboard/issues/419)) ([4a2b1ed](https://github.com/politics-rewired/switchboard/commit/4a2b1ed2c98d8bbe7a5c03b90b26293e2059ab95))
* update lookup to use telnyx v2 api ([#417](https://github.com/politics-rewired/switchboard/issues/417)) ([d89bb97](https://github.com/politics-rewired/switchboard/commit/d89bb978d36eeb7019967bb8f9ed2ae1afc5f1e6))

### [4.0.3](https://github.com/politics-rewired/switchboard/compare/v4.0.2...v4.0.3) (2023-11-29)


### Bug Fixes

* **twilio:** upgrade to v4.18.1 ([#416](https://github.com/politics-rewired/switchboard/issues/416)) ([7832a69](https://github.com/politics-rewired/switchboard/commit/7832a69cca812c22727978b93d4763c42adc7f21))

### [4.0.2](https://github.com/politics-rewired/switchboard/compare/v4.0.1...v4.0.2) (2023-07-27)


### Bug Fixes

* **hotfix:** update telnyx dlr schema for delivery_failed and sending_failed ([96265bb](https://github.com/politics-rewired/switchboard/commit/96265bbe6f7fd8cf7a738527c91e3ea4d11fad01))

### [4.0.1](https://github.com/politics-rewired/switchboard/compare/v4.0.0...v4.0.1) (2023-07-26)


### Bug Fixes

* add missing . to worker event prefix ([#402](https://github.com/politics-rewired/switchboard/issues/402)) ([d54e54f](https://github.com/politics-rewired/switchboard/commit/d54e54fa0b32e25a8384befbb78c8a73860f00f1))
* fix delivery report shape ([#404](https://github.com/politics-rewired/switchboard/issues/404)) ([66f589d](https://github.com/politics-rewired/switchboard/commit/66f589ddce963fc4caa959d88ea7bcd12d718307))
* park failed cron jobs ([#403](https://github.com/politics-rewired/switchboard/issues/403)) ([85614c0](https://github.com/politics-rewired/switchboard/commit/85614c07b7cd258e864a1b11c67e5fcca71115fc))


### Backend Changes

* fix slow rollup query ([#406](https://github.com/politics-rewired/switchboard/issues/406)) ([6ff3ff5](https://github.com/politics-rewired/switchboard/commit/6ff3ff5952024706ce658712eea479b8ea8f83f2))

## [4.0.0](https://github.com/politics-rewired/switchboard/compare/v4.0.0-rc.8...v4.0.0) (2023-07-24)

## [4.0.0-rc.8](https://github.com/politics-rewired/switchboard/compare/v4.0.0-rc.7...v4.0.0-rc.8) (2023-07-23)


### Bug Fixes

* skip hydrating decomissioned sending locations ([#401](https://github.com/politics-rewired/switchboard/issues/401)) ([3c63829](https://github.com/politics-rewired/switchboard/commit/3c63829312abcf8c207a2814c8c3c9cc2c7e2f25))

## [4.0.0-rc.7](https://github.com/politics-rewired/switchboard/compare/v4.0.0-rc.6...v4.0.0-rc.7) (2023-07-23)


### Backend Changes

* **hotfix:** log sending location for Incorrect10DlcNumberCountError ([#400](https://github.com/politics-rewired/switchboard/issues/400)) ([266430a](https://github.com/politics-rewired/switchboard/commit/266430ab884bca1ab927de64e0e3e6ab927c78a6))

## [4.0.0-rc.6](https://github.com/politics-rewired/switchboard/compare/v4.0.0-rc.5...v4.0.0-rc.6) (2023-07-22)


### Bug Fixes

* **hotfix:** pass pg pool instead of slonik pool ([bf242a5](https://github.com/politics-rewired/switchboard/commit/bf242a5cfadb0ebfb84e63d8dcb7e89cd48cd061))

## [4.0.0-rc.5](https://github.com/politics-rewired/switchboard/compare/v4.0.0-rc.4...v4.0.0-rc.5) (2023-07-21)


### Backend Changes

* Add default TZ in env example ([#388](https://github.com/politics-rewired/switchboard/issues/388)) ([b6c2dda](https://github.com/politics-rewired/switchboard/commit/b6c2dda6367f3857df2a3ed133d8f89af028a224))
* park failed jobs ([#399](https://github.com/politics-rewired/switchboard/issues/399)) ([1a32318](https://github.com/politics-rewired/switchboard/commit/1a323185412795792a8752c66ba45978ed8dff58))

## [4.0.0-rc.4](https://github.com/politics-rewired/switchboard/compare/v4.0.0-rc.3...v4.0.0-rc.4) (2023-07-12)


### Bug Fixes

* hotfix import of event emitter ([7e661af](https://github.com/politics-rewired/switchboard/commit/7e661afe1dbd86688ddde38a84529efb39293783))

## [4.0.0-rc.3](https://github.com/politics-rewired/switchboard/compare/v4.0.0-rc.2...v4.0.0-rc.3) (2023-07-12)


### Features

* add worker statsd emitter ([#397](https://github.com/politics-rewired/switchboard/issues/397)) ([9f0c3ee](https://github.com/politics-rewired/switchboard/commit/9f0c3ee48ed326bfabdee4d1c2ede212c9ac1fab))


### Bug Fixes

* register notice-sending-location-change task ([#393](https://github.com/politics-rewired/switchboard/issues/393)) ([2f02f25](https://github.com/politics-rewired/switchboard/commit/2f02f2527ed37220110874c47e1dee3862ec3aac))


### Backend Changes

* drop unused columns on outbound_messages ([#395](https://github.com/politics-rewired/switchboard/issues/395)) ([65cc66c](https://github.com/politics-rewired/switchboard/commit/65cc66c5c942ebd7e28112d9f8672bbcfd08df04))

## [4.0.0-rc.2](https://github.com/politics-rewired/switchboard/compare/v4.0.0-rc.1...v4.0.0-rc.2) (2023-07-07)


### Features

* validate task payloads with zod ([#391](https://github.com/politics-rewired/switchboard/issues/391)) ([e39e550](https://github.com/politics-rewired/switchboard/commit/e39e5508b894de1ff2f2e64e3fdeca8819e08948))


### Backend Changes

* use constants for task identifiers ([#390](https://github.com/politics-rewired/switchboard/issues/390)) ([1d91ea7](https://github.com/politics-rewired/switchboard/commit/1d91ea734b2bc7e2c43aa6464b0c8e1f53c204d4))

## [4.0.0-rc.1](https://github.com/politics-rewired/switchboard/compare/v4.0.0-rc.0...v4.0.0-rc.1) (2023-07-06)


### Bug Fixes

* add ioredis-mock as prod dependency ([314f073](https://github.com/politics-rewired/switchboard/commit/314f0735dd3a08fcc82d0043a164add15a099014))

## [4.0.0-rc.0](https://github.com/politics-rewired/switchboard/compare/v3.4.0-rc.0...v4.0.0-rc.0) (2023-07-05)


### ⚠ BREAKING CHANGES

* eject assemble-worker (#373)

### Features

* use redis for caching profile and sending account info ([#387](https://github.com/politics-rewired/switchboard/issues/387)) ([7fec8e1](https://github.com/politics-rewired/switchboard/commit/7fec8e18d7727f255e04186bea3c123248086a08))


### Backend Changes

* add cache-backed process-10dlc-message ([#384](https://github.com/politics-rewired/switchboard/issues/384)) ([267f237](https://github.com/politics-rewired/switchboard/commit/267f237bc32bb35605e261b5f67a9f19e9bca60d))
* eject assemble-worker ([#373](https://github.com/politics-rewired/switchboard/issues/373)) ([bc9f664](https://github.com/politics-rewired/switchboard/commit/bc9f6646fedb8fa33d26b02b1c091bc1d90b74be))

## [3.4.0-rc.0](https://github.com/politics-rewired/switchboard/compare/v3.3.4...v3.4.0-rc.0) (2023-06-30)


### Features

* add dry run service and mode ([#378](https://github.com/politics-rewired/switchboard/issues/378)) ([b512fe1](https://github.com/politics-rewired/switchboard/commit/b512fe1fe14aed84432a564e213f5ac507c707a2))

### [3.3.4](https://github.com/politics-rewired/switchboard/compare/v3.3.3...v3.3.4) (2023-06-29)


### Bug Fixes

* handle case where dlr match is not found ([#382](https://github.com/politics-rewired/switchboard/issues/382)) ([5373320](https://github.com/politics-rewired/switchboard/commit/5373320cddf36e493792c5ce019b396a7df21745))


### Backend Changes

* enable TS strict mode ([#386](https://github.com/politics-rewired/switchboard/issues/386)) ([5582044](https://github.com/politics-rewired/switchboard/commit/558204436676694cd9b7b72aa384d8fad7301855))
* pull up common process message functionality ([#383](https://github.com/politics-rewired/switchboard/issues/383)) ([aacd1d7](https://github.com/politics-rewired/switchboard/commit/aacd1d76e3f7ab12c48834cec84d0a9f0ce21fb7))

### [3.3.3](https://github.com/politics-rewired/switchboard/compare/v3.3.2...v3.3.3) (2023-06-16)


### Bug Fixes

* update cron task payload shape ([#377](https://github.com/politics-rewired/switchboard/issues/377)) ([b6c77c3](https://github.com/politics-rewired/switchboard/commit/b6c77c3df9cbbdc7d772d18418dde46ec42b5ee8))

### [3.3.2](https://github.com/politics-rewired/switchboard/compare/v3.3.1...v3.3.2) (2023-06-15)


### Bug Fixes

* **graphile-worker:** fix cron item param name ([96cbda8](https://github.com/politics-rewired/switchboard/commit/96cbda8508f43cb40b7626bdce27ffdbcae7b53b))


### Backend Changes

* migrate graphile-scheduler to graphile-worker cron ([#375](https://github.com/politics-rewired/switchboard/issues/375)) ([cf3cf76](https://github.com/politics-rewired/switchboard/commit/cf3cf760cb14ccfbbf6d00c01973bc646cfab421))
* upgrade graphile-worker to v0.14.0 ([#370](https://github.com/politics-rewired/switchboard/issues/370)) ([e7c9204](https://github.com/politics-rewired/switchboard/commit/e7c92040f0d71be9141f89c69303ac16a0d5e702))
* **conventional-commits:** set explicit types ([#374](https://github.com/politics-rewired/switchboard/issues/374)) ([8b99654](https://github.com/politics-rewired/switchboard/commit/8b99654ce880685428ababe549861321fb622c1d))

### [3.3.1](https://github.com/politics-rewired/switchboard/compare/v3.3.0...v3.3.1) (2023-06-15)


### Bug Fixes

* enable non-generic query plan for sms.resolve_delivery_reports() ([#372](https://github.com/politics-rewired/switchboard/issues/372)) ([6184660](https://github.com/politics-rewired/switchboard/commit/6184660c5241b8c93f0e57ea015efb6569278aba))
* use supported graphile worker api ([#369](https://github.com/politics-rewired/switchboard/issues/369)) ([e60b714](https://github.com/politics-rewired/switchboard/commit/e60b7141214ddbe907798c4092900802f04f94f4))

## [3.3.0](https://github.com/politics-rewired/switchboard/compare/v3.2.0...v3.3.0) (2023-06-09)


### Features

* add channel-specific provisioning for new GraphQL-created sending locations ([#367](https://github.com/politics-rewired/switchboard/issues/367)) ([088c6b6](https://github.com/politics-rewired/switchboard/commit/088c6b673932ad9b804490ddfef61da74aa79a02))

## [3.2.0](https://github.com/politics-rewired/switchboard/compare/v3.1.1...v3.2.0) (2023-06-06)


### Features

* automate daily maintenance of high-write tables ([#366](https://github.com/politics-rewired/switchboard/issues/366)) ([dd838c2](https://github.com/politics-rewired/switchboard/commit/dd838c22987f2eb5e025e56393c29313d43034f7))
* resolve bandwidth delivery reports ([#361](https://github.com/politics-rewired/switchboard/issues/361)) ([e02d7d1](https://github.com/politics-rewired/switchboard/commit/e02d7d15c291fd2ae80812597fe8806b2bf84844))

### [3.1.1](https://github.com/politics-rewired/switchboard/compare/v3.1.0...v3.1.1) (2023-04-17)


### Bug Fixes

* 200 response for unmatched inbounds ([#351](https://github.com/politics-rewired/switchboard/issues/351)) ([c2f316e](https://github.com/politics-rewired/switchboard/commit/c2f316e6e222d23d4666ff624c33c41dd08b9f70))
* **docs:** update readme and add nvmrc ([#342](https://github.com/politics-rewired/switchboard/issues/342)) ([29d1cba](https://github.com/politics-rewired/switchboard/commit/29d1cba3177411b6856ee3683349796e2f3b5107))

## [3.1.0](https://github.com/politics-rewired/switchboard/compare/v3.0.0...v3.1.0) (2023-01-09)


### Features

* add 10dlc channel ([#325](https://github.com/politics-rewired/switchboard/issues/325)) ([3554d67](https://github.com/politics-rewired/switchboard/commit/3554d67af7b380ea5ce30bd77db102704720753a))


### Bug Fixes

* prevent routing to fulfilled pending requests ([#338](https://github.com/politics-rewired/switchboard/issues/338)) ([7e9293d](https://github.com/politics-rewired/switchboard/commit/7e9293d5b88db2048b7b0dc2fd68f1b4b0883ba9))
* **forward-inbound-message:** log unexpected errors ([#340](https://github.com/politics-rewired/switchboard/issues/340)) ([57608d0](https://github.com/politics-rewired/switchboard/commit/57608d0224030115e4a8fde8b4daeaae97731dcf))

## [3.0.0](https://github.com/politics-rewired/switchboard/compare/v2.15.1...v3.0.0) (2022-10-27)


### ⚠ BREAKING CHANGES

* process grey route to redis (#327)

### Features

* process grey route to redis ([#327](https://github.com/politics-rewired/switchboard/issues/327)) ([e5f617d](https://github.com/politics-rewired/switchboard/commit/e5f617d637c568becd410d1c0437d643532fc3f4))

### [2.15.1](https://github.com/politics-rewired/switchboard/compare/v2.15.0...v2.15.1) (2022-09-30)


### Bug Fixes

* pass correct campaign id ([#333](https://github.com/politics-rewired/switchboard/issues/333)) ([0181623](https://github.com/politics-rewired/switchboard/commit/0181623a9bc1d688eea64b6b066a72ea03006f22))

## [2.15.0](https://github.com/politics-rewired/switchboard/compare/v2.14.2...v2.15.0) (2022-09-28)


### Features

* use shared task list ([#330](https://github.com/politics-rewired/switchboard/issues/330)) ([07fec0f](https://github.com/politics-rewired/switchboard/commit/07fec0f4c427fb1add5e007abadf636159f634cd))

### [2.14.2](https://github.com/politics-rewired/switchboard/compare/v2.14.1...v2.14.2) (2022-09-28)


### Bug Fixes

* fix transaction usage in wrapper ([#331](https://github.com/politics-rewired/switchboard/issues/331)) ([6213963](https://github.com/politics-rewired/switchboard/commit/6213963d4cfd03977d9fad287bf2098eff2c12d8))

### [2.14.1](https://github.com/politics-rewired/switchboard/compare/v2.14.0...v2.14.1) (2022-09-27)


### Bug Fixes

* fix backfill of tendlc_campaign ids ([a288952](https://github.com/politics-rewired/switchboard/commit/a288952a826d39bf1b1a0b7830424c793268dcf0))

## [2.14.0](https://github.com/politics-rewired/switchboard/compare/v2.13.3...v2.14.0) (2022-09-27)


### Features

* add 10DLC campaigns ([#322](https://github.com/politics-rewired/switchboard/issues/322)) ([6367c80](https://github.com/politics-rewired/switchboard/commit/6367c80c8367d2cab3af23ce0d897da150ed73cb))
* add 10DLC MNO metadata ([#323](https://github.com/politics-rewired/switchboard/issues/323)) ([dfc52e2](https://github.com/politics-rewired/switchboard/commit/dfc52e24efe9b424622eb64b2434d5baa390b163))
* support TCR sending accounts ([#321](https://github.com/politics-rewired/switchboard/issues/321)) ([a67fcce](https://github.com/politics-rewired/switchboard/commit/a67fccebd25bc3ce9caabb0d1697da8397219871))


### Bug Fixes

* delete fresh phone commits when decmomissioning numbers ([#329](https://github.com/politics-rewired/switchboard/issues/329)) ([f27ff43](https://github.com/politics-rewired/switchboard/commit/f27ff43a2193e44e9e7102612dcef1d74eb2b575))
* fix partial index for invalidating from number mappings ([#328](https://github.com/politics-rewired/switchboard/issues/328)) ([ca5e2f0](https://github.com/politics-rewired/switchboard/commit/ca5e2f01c30e2a280f93253745326d7413f5d0fe))

### [2.13.3](https://github.com/politics-rewired/switchboard/compare/v2.13.2...v2.13.3) (2022-09-19)


### Bug Fixes

* resolve messages awaiting from numbers in task ([#324](https://github.com/politics-rewired/switchboard/issues/324)) ([12a4663](https://github.com/politics-rewired/switchboard/commit/12a4663c9b053b51e63ad95824b6fb14a88db51a))

### [2.13.2](https://github.com/politics-rewired/switchboard/compare/v2.13.1...v2.13.2) (2022-09-19)


### Bug Fixes

* add to_number to from_number_mappings backfill distinctness ([e60a646](https://github.com/politics-rewired/switchboard/commit/e60a646e154622a07c0743a8c56dd4f2d76d6350))

### [2.13.1](https://github.com/politics-rewired/switchboard/compare/v2.13.0...v2.13.1) (2022-09-19)


### Bug Fixes

* add last_used_at to backfill ([d22eb40](https://github.com/politics-rewired/switchboard/commit/d22eb400ae2aecb32e7127fbf3f460bec36a3414))

## [2.13.0](https://github.com/politics-rewired/switchboard/compare/v2.12.0...v2.13.0) (2022-09-19)


### Features

* add prev mapping table ([#311](https://github.com/politics-rewired/switchboard/issues/311)) ([4b354d9](https://github.com/politics-rewired/switchboard/commit/4b354d97d53718ebb65bcfa9b0c140f78e6c828e))


### Bug Fixes

* handle webhook 3xx redirects correctly ([#318](https://github.com/politics-rewired/switchboard/issues/318)) ([1424a62](https://github.com/politics-rewired/switchboard/commit/1424a62ecc82534b11222dd87f10343459f03d0e))

## [2.12.0](https://github.com/politics-rewired/switchboard/compare/v2.11.4...v2.12.0) (2022-08-17)


### Features

* slow down delivery reports ([#317](https://github.com/politics-rewired/switchboard/issues/317)) ([b435359](https://github.com/politics-rewired/switchboard/commit/b435359eebd494be254f1b4599e998334d13ac43))


### Bug Fixes

* **pg:** override slonik ssl options ([#307](https://github.com/politics-rewired/switchboard/issues/307)) ([cf8d857](https://github.com/politics-rewired/switchboard/commit/cf8d85711dcbdc047399770141029099b1ebc402))

### [2.11.4](https://github.com/politics-rewired/switchboard/compare/v2.11.3...v2.11.4) (2022-08-08)


### Bug Fixes

* **poll-number-order:** increase max attempts ([#313](https://github.com/politics-rewired/switchboard/issues/313)) ([0bd3bef](https://github.com/politics-rewired/switchboard/commit/0bd3befc619f94170560bbbda5836562279b5caa))
* exit on unhandled promise rejection ([#314](https://github.com/politics-rewired/switchboard/issues/314)) ([b9ecf04](https://github.com/politics-rewired/switchboard/commit/b9ecf04fa36f579c7c98548e7f62bff840c344b7))

### [2.11.3](https://github.com/politics-rewired/switchboard/compare/v2.11.2...v2.11.3) (2022-07-28)


### Bug Fixes

* **bandwidth:** fix down migration ([6840ef4](https://github.com/politics-rewired/switchboard/commit/6840ef4079a8d0151a6275daeebab9b48eb5df52))

### [2.11.2](https://github.com/politics-rewired/switchboard/compare/v2.11.1...v2.11.2) (2022-07-28)


### Bug Fixes

* **bandwidth:** include migrations ([6850ec4](https://github.com/politics-rewired/switchboard/commit/6850ec404ef5f8f2949c3510a4f4911091af5048))

### [2.11.1](https://github.com/politics-rewired/switchboard/compare/v2.11.0...v2.11.1) (2022-07-28)


### Bug Fixes

* **bandwidth:** fix 10dlc campaign association ([0ccf738](https://github.com/politics-rewired/switchboard/commit/0ccf738bbb4457477c160ebfe8d7e787b93e7889))

## [2.11.0](https://github.com/politics-rewired/switchboard/compare/v2.10.5...v2.11.0) (2022-07-28)


### Features

* **bandwidth:** support 10dlc campaign tn association ([#310](https://github.com/politics-rewired/switchboard/issues/310)) ([d31fe76](https://github.com/politics-rewired/switchboard/commit/d31fe76d105fb22f20e2ced1fce36994960e4c86))

### [2.10.5](https://github.com/politics-rewired/switchboard/compare/v2.10.4...v2.10.5) (2022-07-25)


### Bug Fixes

* **decomission-sending-location:** avoid using named queues ([#306](https://github.com/politics-rewired/switchboard/issues/306)) ([38b78ce](https://github.com/politics-rewired/switchboard/commit/38b78ce527340e57a9bac1319838e47b873f8497))

### [2.10.4](https://github.com/politics-rewired/switchboard/compare/v2.10.3...v2.10.4) (2022-07-15)


### Bug Fixes

* **telnyx:** support limiting number search quantity ([#308](https://github.com/politics-rewired/switchboard/issues/308)) ([a9057af](https://github.com/politics-rewired/switchboard/commit/a9057af2c2e9e1fdde76484d65494d8233383df1))

### [2.10.3](https://github.com/politics-rewired/switchboard/compare/v2.10.2...v2.10.3) (2022-06-27)


### Bug Fixes

* **telnyx:** account for new error response ([#304](https://github.com/politics-rewired/switchboard/issues/304)) ([55ecd54](https://github.com/politics-rewired/switchboard/commit/55ecd54deb72e430c00bbaa6bf2c6d9f2cd4ca2f))

### [2.10.2](https://github.com/politics-rewired/switchboard/compare/v2.10.1...v2.10.2) (2022-06-24)


### Bug Fixes

* **bandwidth:** handle no available numbers case ([#303](https://github.com/politics-rewired/switchboard/issues/303)) ([c4bfd0b](https://github.com/politics-rewired/switchboard/commit/c4bfd0b85b5a14ebb64c2a41e2367abe7f43494b))

### [2.10.1](https://github.com/politics-rewired/switchboard/compare/v2.10.0...v2.10.1) (2022-06-03)


### Bug Fixes

* **bandwidth:** claim number before initiating purchase order ([#300](https://github.com/politics-rewired/switchboard/issues/300)) ([bf68765](https://github.com/politics-rewired/switchboard/commit/bf68765f4db57be2803c06b30e3fbb7ee8722afa))

## [2.10.0](https://github.com/politics-rewired/switchboard/compare/v2.9.0...v2.10.0) (2022-05-07)


### Features

* add service profiles ([#283](https://github.com/politics-rewired/switchboard/issues/283)) ([0572c16](https://github.com/politics-rewired/switchboard/commit/0572c16bc152366654215670d1d1141b63f466cb))

## [2.9.0](https://github.com/politics-rewired/switchboard/compare/v2.8.0...v2.9.0) (2022-05-07)


### Features

* allow configuring log level ([#285](https://github.com/politics-rewired/switchboard/issues/285)) ([dcfabe3](https://github.com/politics-rewired/switchboard/commit/dcfabe3dc8d747693ff6ca26d121efdf0f2138c2))


### Bug Fixes

* set explicit index name and fix down migration ([#293](https://github.com/politics-rewired/switchboard/issues/293)) ([d2cce32](https://github.com/politics-rewired/switchboard/commit/d2cce326b366810e06a66dd4de3f27d1e2079d45))
* tune querying pending number request capacity ([#292](https://github.com/politics-rewired/switchboard/issues/292)) ([b7f7a1f](https://github.com/politics-rewired/switchboard/commit/b7f7a1f757a399e6d1c5b7a67028612e003d8b9e))

## [2.8.0](https://github.com/politics-rewired/switchboard/compare/v2.7.0...v2.8.0) (2022-04-25)


### Features

* add toll-free channel: relations and sending ([#288](https://github.com/politics-rewired/switchboard/issues/288)) ([87aa124](https://github.com/politics-rewired/switchboard/commit/87aa124e93043e0ce502aebe1cc83621395f9386))
* **lookup:** expose additional lrn data ([#289](https://github.com/politics-rewired/switchboard/issues/289)) ([ebd415a](https://github.com/politics-rewired/switchboard/commit/ebd415ae827c1b5e877d39a4a7b2ad75a0215cc6))


### Bug Fixes

* update trigger security for creating sending locations ([#290](https://github.com/politics-rewired/switchboard/issues/290)) ([4b88f3b](https://github.com/politics-rewired/switchboard/commit/4b88f3ba19d410c3b82d9cb149253861592a15cf))

## [2.7.0](https://github.com/politics-rewired/switchboard/compare/v2.6.1...v2.7.0) (2022-04-20)


### Features

* add bandwidth service ([#284](https://github.com/politics-rewired/switchboard/issues/284)) ([1bdc9ca](https://github.com/politics-rewired/switchboard/commit/1bdc9cacb13bbe131ffb0b1087bc3392a99a0c2c))

### [2.6.1](https://github.com/politics-rewired/switchboard/compare/v2.6.0...v2.6.1) (2022-04-20)

## [2.6.0](https://github.com/politics-rewired/switchboard/compare/v2.5.4...v2.6.0) (2022-04-01)


### Features

* switch to service classes ([#275](https://github.com/politics-rewired/switchboard/issues/275)) ([4079122](https://github.com/politics-rewired/switchboard/commit/4079122f3bb611df2963ade1382818298952cdc3))

### [2.5.4](https://github.com/politics-rewired/switchboard/compare/v2.5.3...v2.5.4) (2022-03-28)


### Bug Fixes

* do not replace PhoneNumber scalar with String ([#267](https://github.com/politics-rewired/switchboard/issues/267)) ([7e8bfa6](https://github.com/politics-rewired/switchboard/commit/7e8bfa67f5a2569f4cf7e1e997d3ece03e41afe3))
* handle delivery report with null error codes ([#265](https://github.com/politics-rewired/switchboard/issues/265)) ([0e71dd6](https://github.com/politics-rewired/switchboard/commit/0e71dd6d6e0e8d5de40e9514d3696f4bcba598bf))
* handle promise rejection in auth ([#270](https://github.com/politics-rewired/switchboard/issues/270)) ([f42e8cd](https://github.com/politics-rewired/switchboard/commit/f42e8cdc641435f34560d89ba911c1b8dbf21d15)), closes [#260](https://github.com/politics-rewired/switchboard/issues/260)
* use 401 unauthorized response for missing token ([#271](https://github.com/politics-rewired/switchboard/issues/271)) ([4005961](https://github.com/politics-rewired/switchboard/commit/4005961247b2062be58a1806019c8fdd972078cc))

### [2.5.3](https://github.com/politics-rewired/switchboard/compare/v2.5.2...v2.5.3) (2022-03-24)


### Bug Fixes

* fix routing to support graphiql ([#262](https://github.com/politics-rewired/switchboard/issues/262)) ([b669aad](https://github.com/politics-rewired/switchboard/commit/b669aad9a3597a083f523f3409e96e39c20dac61))
* fix running dev:watch with nodemon ([#261](https://github.com/politics-rewired/switchboard/issues/261)) ([08c6344](https://github.com/politics-rewired/switchboard/commit/08c634400872815f5120b149d5c2232e1efd5b8b))
* lock down graphql schema ([#263](https://github.com/politics-rewired/switchboard/issues/263)) ([7299f48](https://github.com/politics-rewired/switchboard/commit/7299f481d3424ea77250d6f3a7c95222557e3154))

### [2.5.2](https://github.com/politics-rewired/switchboard/compare/v2.5.1...v2.5.2) (2022-03-18)


### Bug Fixes

* **tg__sync_profile_provisioned:** make security definer ([#259](https://github.com/politics-rewired/switchboard/issues/259)) ([192a025](https://github.com/politics-rewired/switchboard/commit/192a02581cd9cf0d136ffe822620d08fe0939fd5))

### [2.5.1](https://github.com/politics-rewired/switchboard/compare/v2.5.0...v2.5.1) (2022-03-15)


### Bug Fixes

* update typescript to fix build ([a1b9ae1](https://github.com/politics-rewired/switchboard/commit/a1b9ae1baa0f5da5547645ebe3beb0b07b464471))

## [2.5.0](https://github.com/politics-rewired/switchboard/compare/v2.4.1...v2.5.0) (2022-03-15)


### Features

* codify grey route channel ([#252](https://github.com/politics-rewired/switchboard/issues/252)) ([aece7d3](https://github.com/politics-rewired/switchboard/commit/aece7d31d9d54c895dfd3dfb2194bd6fa491af3e))


### Bug Fixes

* **pending-number-request-capacity:** use new awaiting number table ([#248](https://github.com/politics-rewired/switchboard/issues/248)) ([5cb5093](https://github.com/politics-rewired/switchboard/commit/5cb50932664b07ed78e581c03abe3189b3fddbbd))
* **send-message:** handle invalid from number error ([#256](https://github.com/politics-rewired/switchboard/issues/256)) ([4bbf752](https://github.com/politics-rewired/switchboard/commit/4bbf752e36dd89828463cf45f5ea7141a05d2a11))
* **telnyx:** set profile id in number order ([#253](https://github.com/politics-rewired/switchboard/issues/253)) ([d0d6bf1](https://github.com/politics-rewired/switchboard/commit/d0d6bf1fad2665ab9888b699710571f35cc59d3e))

### [2.4.1](https://github.com/politics-rewired/switchboard/compare/v2.4.0...v2.4.1) (2022-02-03)


### Bug Fixes

* **purchase-number:** log twilio error message ([#249](https://github.com/politics-rewired/switchboard/issues/249)) ([ff21f87](https://github.com/politics-rewired/switchboard/commit/ff21f87cbcf0a52cd8c6a692252f3ef167ed498e))

## [2.4.0](https://github.com/politics-rewired/switchboard/compare/v2.3.1...v2.4.0) (2022-01-07)


### Features

* add awaiting number table ([#245](https://github.com/politics-rewired/switchboard/issues/245)) ([a65f129](https://github.com/politics-rewired/switchboard/commit/a65f1298ff7f906c40a8da12e2dbcca40f6628d5))

### [2.3.1](https://github.com/politics-rewired/switchboard/compare/v2.3.0...v2.3.1) (2021-12-31)


### Bug Fixes

* **auth:** throw error from client ID resolver ([#244](https://github.com/politics-rewired/switchboard/issues/244)) ([9ccaad8](https://github.com/politics-rewired/switchboard/commit/9ccaad8f681e6d40a1677f0fe5c21af6cacf4f45))

## [2.3.0](https://github.com/politics-rewired/switchboard/compare/v2.2.0...v2.3.0) (2021-11-11)


### Features

* add attach_10dlc_campaign_to_profile ([#240](https://github.com/politics-rewired/switchboard/issues/240)) ([92e49dc](https://github.com/politics-rewired/switchboard/commit/92e49dc8e685f4c7d096faae1458bd922342f5bc))


### Bug Fixes

* skip creating jobs during migration backfill ([1415f9c](https://github.com/politics-rewired/switchboard/commit/1415f9ce38d9e1b01ab6d2f95172352a216e5d79))

## [2.2.0](https://github.com/politics-rewired/switchboard/compare/v2.1.2...v2.2.0) (2021-09-29)


### Features

* **v2.x:** support provisioning 10dlc numbers ([#228](https://github.com/politics-rewired/switchboard/issues/228)) ([15dc79e](https://github.com/politics-rewired/switchboard/commit/15dc79e9d0ff563e0b3d10d4809044b4f889d0d1))


### Bug Fixes

* **2.x:** backfill twilio service ids ([#236](https://github.com/politics-rewired/switchboard/issues/236)) ([527c15e](https://github.com/politics-rewired/switchboard/commit/527c15ef1fb6998ca3156d8fc6be753443f3df64))
* **2.x:** perf - avoid full routing table scans ([#224](https://github.com/politics-rewired/switchboard/issues/224)) ([4bff9a3](https://github.com/politics-rewired/switchboard/commit/4bff9a363e042408c0831f2c239454d8262310c1))

### [2.1.2](https://github.com/politics-rewired/switchboard/compare/v2.1.1...v2.1.2) (2021-08-13)


### Bug Fixes

* **v2.x:** prevent duplicate number purchases ([#213](https://github.com/politics-rewired/switchboard/issues/213)) ([d099afe](https://github.com/politics-rewired/switchboard/commit/d099afec89a053474fe35b38396ff08289da632b))

### [2.1.1](https://github.com/politics-rewired/switchboard/compare/v2.1.0...v2.1.1) (2021-07-23)


### Bug Fixes

* cast string to timestamp to fix queue-cost-backfill ([#210](https://github.com/politics-rewired/switchboard/issues/210)) ([d37b14e](https://github.com/politics-rewired/switchboard/commit/d37b14ea899aaa97441daae5101e83330288fffa))

## [2.1.0](https://github.com/politics-rewired/switchboard/compare/v1.18.0...v2.1.0) (2021-04-16)


### ⚠ BREAKING CHANGES

* **timescaledb:** Requires running against postgres database with timescale extension installed.

### Features

* allow configuring per-number limits ([#206](https://github.com/politics-rewired/switchboard/issues/206)) ([e86e41d](https://github.com/politics-rewired/switchboard/commit/e86e41d64addc62abd1edc2c03d0e8e8cfdce467))
* **timescaledb:** use timescaledb ([#203](https://github.com/politics-rewired/switchboard/issues/203)) ([23e9bf3](https://github.com/politics-rewired/switchboard/commit/23e9bf30d97d242df9807dd0dd0e661f1fefb76c))


### Bug Fixes

* perf improvements ([#207](https://github.com/politics-rewired/switchboard/issues/207)) ([6f028be](https://github.com/politics-rewired/switchboard/commit/6f028be7e6bc937fdad4a58fcb3d47c657858c3f))

## [2.0.0](https://github.com/politics-rewired/switchboard/compare/v1.18.0...v2.0.0) (2021-04-06)


### ⚠ BREAKING CHANGES

* **timescaledb:** Requires running against postgres database with timescale extension installed.

### Features

* allow configuring per-number limits ([#206](https://github.com/politics-rewired/switchboard/issues/206)) ([e86e41d](https://github.com/politics-rewired/switchboard/commit/e86e41d64addc62abd1edc2c03d0e8e8cfdce467))
* **timescaledb:** use timescaledb ([#203](https://github.com/politics-rewired/switchboard/issues/203)) ([23e9bf3](https://github.com/politics-rewired/switchboard/commit/23e9bf30d97d242df9807dd0dd0e661f1fefb76c))

## [1.18.0](https://github.com/politics-rewired/switchboard/compare/v1.14.2...v1.18.0) (2021-03-12)


### Features

* add migrations for stripe billing data ([#93](https://github.com/politics-rewired/switchboard/issues/93)) ([c46c6ae](https://github.com/politics-rewired/switchboard/commit/c46c6ae0c86572d4e3a6be273d13dc3f771c3ef5))
* add usage rollups ([#198](https://github.com/politics-rewired/switchboard/issues/198)) ([512ab03](https://github.com/politics-rewired/switchboard/commit/512ab032dd5c905ec7123fc15bb260748d0df58b))
* **docs:** timescale designs ([#201](https://github.com/politics-rewired/switchboard/issues/201)) ([5bc2161](https://github.com/politics-rewired/switchboard/commit/5bc2161ccf8e66e4734017d8a65d213c9dc4c691))
* **outbound_messages_routing:** simply prev mapping idx ([#174](https://github.com/politics-rewired/switchboard/issues/174)) ([878a4ff](https://github.com/politics-rewired/switchboard/commit/878a4ffd8efbeb91beb246ba1260d986f3ee1602))


### Bug Fixes

* **usage-rollups:** unique periods ([ee6afa5](https://github.com/politics-rewired/switchboard/commit/ee6afa523773a2eb452a481fec18e57e42dcceee))
* fix syntax for queue-backfill-cost ([#204](https://github.com/politics-rewired/switchboard/issues/204)) ([c8df496](https://github.com/politics-rewired/switchboard/commit/c8df496c36986f6ed1e90cfe3dd54063c5007900))
* rollup usage ([#205](https://github.com/politics-rewired/switchboard/issues/205)) ([5265c6d](https://github.com/politics-rewired/switchboard/commit/5265c6ded9e6a78ed6fcd127b79759f253616182))

## [1.17.0](https://github.com/politics-rewired/switchboard/compare/v1.16.0...v1.17.0) (2021-03-09)


### Features

* add usage rollups ([#198](https://github.com/politics-rewired/switchboard/issues/198)) ([512ab03](https://github.com/politics-rewired/switchboard/commit/512ab032dd5c905ec7123fc15bb260748d0df58b))

## [1.16.0](https://github.com/politics-rewired/switchboard/compare/v1.15.0...v1.16.0) (2021-03-05)


### Features

* add migrations for stripe billing data ([#93](https://github.com/politics-rewired/switchboard/issues/93)) ([c46c6ae](https://github.com/politics-rewired/switchboard/commit/c46c6ae0c86572d4e3a6be273d13dc3f771c3ef5))


### Bug Fixes

* fix syntax for queue-backfill-cost ([#204](https://github.com/politics-rewired/switchboard/issues/204)) ([c8df496](https://github.com/politics-rewired/switchboard/commit/c8df496c36986f6ed1e90cfe3dd54063c5007900))

## [1.15.0](https://github.com/politics-rewired/switchboard/compare/v1.14.2...v1.15.0) (2021-02-26)


### Features

* **docs:** timescale designs ([#201](https://github.com/politics-rewired/switchboard/issues/201)) ([5bc2161](https://github.com/politics-rewired/switchboard/commit/5bc2161ccf8e66e4734017d8a65d213c9dc4c691))
* **outbound_messages_routing:** simply prev mapping idx ([#174](https://github.com/politics-rewired/switchboard/issues/174)) ([878a4ff](https://github.com/politics-rewired/switchboard/commit/878a4ffd8efbeb91beb246ba1260d986f3ee1602))

### [1.14.2](https://github.com/politics-rewired/switchboard/compare/v1.14.1...v1.14.2) (2020-11-05)


### Bug Fixes

* **backfill-cost:** oldRows update path ([#197](https://github.com/politics-rewired/switchboard/issues/197)) ([94e8f8d](https://github.com/politics-rewired/switchboard/commit/94e8f8d03d4570fb4ea2409437af8428caf2b9a6))

### [1.14.1](https://github.com/politics-rewired/switchboard/compare/v1.14.0...v1.14.1) (2020-11-04)


### Bug Fixes

* **worker:** dont run graphile worker if no tasks ([c7c4af8](https://github.com/politics-rewired/switchboard/commit/c7c4af812088c42c21ef532c86cef26a290a9e71))

## [1.14.0](https://github.com/politics-rewired/switchboard/compare/v1.13.0...v1.14.0) (2020-10-29)


### Features

* **purchase-number:** configurable concurrency ([#192](https://github.com/politics-rewired/switchboard/issues/192)) ([1fce891](https://github.com/politics-rewired/switchboard/commit/1fce891870e56e6e9c6eb26fa4eaebe607d123ce))

## [1.13.0](https://github.com/politics-rewired/switchboard/compare/v1.12.0...v1.13.0) (2020-10-26)


### Features

* **purchase-number:** use telnyx best effort ([#183](https://github.com/politics-rewired/switchboard/issues/183)) ([67aa467](https://github.com/politics-rewired/switchboard/commit/67aa467548650953b305f06d1a9ca732d6bf9fdd))
* **send-message:** move to higher concurrency assemble-worker ([#180](https://github.com/politics-rewired/switchboard/issues/180)) ([ba3a22e](https://github.com/politics-rewired/switchboard/commit/ba3a22e707921f6107217507ade019540c394773))
* **send-message:** perf logging ([#186](https://github.com/politics-rewired/switchboard/issues/186)) ([0a50bf6](https://github.com/politics-rewired/switchboard/commit/0a50bf6aea66292d713eb7040ec45aca6bf36bce))


### Bug Fixes

* perform send-message in transaction ([#184](https://github.com/politics-rewired/switchboard/issues/184)) ([f76e8e6](https://github.com/politics-rewired/switchboard/commit/f76e8e6a6158be6706a1ec7efeef506540e44fa5))
* **forward-delivery-report:** better query ([6887cff](https://github.com/politics-rewired/switchboard/commit/6887cffcb0b2ec405271bebd4e8af6180ba2eea6))
* **forward-delivery-report:** handle already updated delivery report ([1c5ee22](https://github.com/politics-rewired/switchboard/commit/1c5ee22b622f65ff38baeaaee3157d831411b279))
* **forward-delivery-report:** working query ([8d9b621](https://github.com/politics-rewired/switchboard/commit/8d9b6215183dfd4e0ea504a4ba37df4392103d5c))
* **fulfill-request:** join on indexed column ([#189](https://github.com/politics-rewired/switchboard/issues/189)) ([924ac17](https://github.com/politics-rewired/switchboard/commit/924ac17978d7459dabc245215b7424e2f34cccca))
* **sell-number:** one job at a time ([#175](https://github.com/politics-rewired/switchboard/issues/175)) ([3c008a5](https://github.com/politics-rewired/switchboard/commit/3c008a5d543519ccc14932e84a3708fa3d212fc6))
* **worker:** accidentally set concurrency to 1 ([323a041](https://github.com/politics-rewired/switchboard/commit/323a0419324cbde1d16f0855cb44ca2293ed67a6))
* **worker:** remove final trailing comma ([6aea527](https://github.com/politics-rewired/switchboard/commit/6aea5275ab84435da4f87cb4340f9a59158b981c))
* add missing select ([050f578](https://github.com/politics-rewired/switchboard/commit/050f578b6ef0664cace95e49a26e970be33c28c5))
* **send-message:** construct date with explicit UTC timezone ([#178](https://github.com/politics-rewired/switchboard/issues/178)) ([2f0dd27](https://github.com/politics-rewired/switchboard/commit/2f0dd27472bd1877cd5a9625c47ab612b736a907))

## [1.12.0](https://github.com/politics-rewired/switchboard/compare/v1.11.1...v1.12.0) (2020-10-23)


### Features

* **forward-delivery-report:** message id resoluton in forward job ([#177](https://github.com/politics-rewired/switchboard/issues/177)) ([eb2fd1d](https://github.com/politics-rewired/switchboard/commit/eb2fd1d894c126ad4833da1806176e3680d89494))
* **process-message:** make prev mapping validity configurable via env ([#176](https://github.com/politics-rewired/switchboard/issues/176)) ([aaa2a34](https://github.com/politics-rewired/switchboard/commit/aaa2a34e65d2f254dd20dd5cb9604e696830e0d0))

### [1.11.1](https://github.com/politics-rewired/switchboard/compare/v1.11.0...v1.11.1) (2020-10-20)


### Bug Fixes

* **forward-delivery-report:** dont use unindexed routing.id ([#173](https://github.com/politics-rewired/switchboard/issues/173)) ([58d31b2](https://github.com/politics-rewired/switchboard/commit/58d31b2204277d550a3d6da344ca9d5e2f94f7bb))

## [1.11.0](https://github.com/politics-rewired/switchboard/compare/v1.10.0...v1.11.0) (2020-10-20)


### Features

* **process-message:** optionally skip old outbound messages check ([5061312](https://github.com/politics-rewired/switchboard/commit/5061312949cadc788b5cc89ef665ae94b4be9bc6))
* **process-message:** optionally skip old outbound messages check ([#171](https://github.com/politics-rewired/switchboard/issues/171)) ([f565f9d](https://github.com/politics-rewired/switchboard/commit/f565f9dec78e8bb78387f239de863e497e2de0ec))
* **send-message:** move to graphile worker ([#168](https://github.com/politics-rewired/switchboard/issues/168)) ([df38efd](https://github.com/politics-rewired/switchboard/commit/df38efd63bd6d4f8ee636f9372870808908c8d21))
* backfill twilio cost ([#167](https://github.com/politics-rewired/switchboard/issues/167)) ([44e310b](https://github.com/politics-rewired/switchboard/commit/44e310b50a5d20563ed1471aa6b38848d7ec0481))


### Bug Fixes

* **resolve-delivery-reports:** resolve bby firedate ([#172](https://github.com/politics-rewired/switchboard/issues/172)) ([380a49c](https://github.com/politics-rewired/switchboard/commit/380a49ce3e26476647305eae0c3859d3cefb8f8a))

## [1.10.0](https://github.com/politics-rewired/switchboard/compare/v1.9.0...v1.10.0) (2020-10-14)


### Features

* **graphile-worker:** env var concurrency ([#166](https://github.com/politics-rewired/switchboard/issues/166)) ([f20076d](https://github.com/politics-rewired/switchboard/commit/f20076dc16e03714922249625ca54f6d21cb3a8e))

## [1.9.0](https://github.com/politics-rewired/switchboard/compare/v1.7.0...v1.9.0) (2020-10-14)


### Features

* outbound message routing ([#162](https://github.com/politics-rewired/switchboard/issues/162)) ([e816d4d](https://github.com/politics-rewired/switchboard/commit/e816d4d0b70e0a1cceb6b342bc82c47e040e4802))


### Bug Fixes

* assemble task wrapping ([#163](https://github.com/politics-rewired/switchboard/issues/163)) ([e88f8db](https://github.com/politics-rewired/switchboard/commit/e88f8db2f1e08ad62575824452bece7cedecdd12))
* drop or update old outbound_messages indexes ([#164](https://github.com/politics-rewired/switchboard/issues/164)) ([b003c6e](https://github.com/politics-rewired/switchboard/commit/b003c6ec6d4c23fff0059916e145cd2fb0367a44))

### [1.8.1](https://github.com/politics-rewired/switchboard/compare/v1.8.0...v1.8.1) (2020-10-13)


### Bug Fixes

* assemble task wrapping ([#163](https://github.com/politics-rewired/switchboard/issues/163)) ([e88f8db](https://github.com/politics-rewired/switchboard/commit/e88f8db2f1e08ad62575824452bece7cedecdd12))
* drop or update old outbound_messages indexes ([#164](https://github.com/politics-rewired/switchboard/issues/164)) ([b003c6e](https://github.com/politics-rewired/switchboard/commit/b003c6ec6d4c23fff0059916e145cd2fb0367a44))

## [1.8.0](https://github.com/politics-rewired/switchboard/compare/v1.7.0...v1.8.0) (2020-10-08)


### Features

* outbound message routing ([#162](https://github.com/politics-rewired/switchboard/issues/162)) ([e816d4d](https://github.com/politics-rewired/switchboard/commit/e816d4d0b70e0a1cceb6b342bc82c47e040e4802))

## [1.7.0](https://github.com/politics-rewired/switchboard/compare/v1.6.4...v1.7.0) (2020-10-02)


### Features

* store network data separately ([#159](https://github.com/politics-rewired/switchboard/issues/159)) ([116cee1](https://github.com/politics-rewired/switchboard/commit/116cee1848af50621338cbe0a124883bf0c3b492))


### Bug Fixes

* reconcile prod schema ([#155](https://github.com/politics-rewired/switchboard/issues/155)) ([4eb1a08](https://github.com/politics-rewired/switchboard/commit/4eb1a08aab3be9e0370c2a7b47568a4e973f0783))

### [1.6.4](https://github.com/politics-rewired/switchboard/compare/v1.6.3...v1.6.4) (2020-10-01)


### Bug Fixes

* pass GraphileWorkerLogger instance ([#157](https://github.com/politics-rewired/switchboard/issues/157)) ([47b8ae3](https://github.com/politics-rewired/switchboard/commit/47b8ae35fbfe62edd769e4aee37e8a8e916e8471))
* **worker:** temp disable graphile logger ([47be3c2](https://github.com/politics-rewired/switchboard/commit/47be3c2a023cd772f4aa54acf6649c65b4515432))

### [1.6.3](https://github.com/politics-rewired/switchboard/compare/v1.6.1...v1.6.3) (2020-09-25)

### [1.6.2](https://github.com/politics-rewired/switchboard/compare/v1.6.1...v1.6.2) (2020-09-25)

### [1.6.1](https://github.com/politics-rewired/switchboard/compare/v1.6.0...v1.6.1) (2020-09-24)


### Bug Fixes

* **send-message:** positive validitiy period ([2046fba](https://github.com/politics-rewired/switchboard/commit/2046fbade0d4384e9a5ee987912983b7fae64e3a))

## [1.6.0](https://github.com/politics-rewired/switchboard/compare/v1.5.2...v1.6.0) (2020-09-24)


### Features

* **send-message:** add send before parameter ([#150](https://github.com/politics-rewired/switchboard/issues/150)) ([d250bdf](https://github.com/politics-rewired/switchboard/commit/d250bdf1a967d70d8aabe9e230ea7e850c8ce77e))


### Bug Fixes

* **worker:** properly rollback transaction ([0a079a8](https://github.com/politics-rewired/switchboard/commit/0a079a800ad6dcf45c71944316e2231d40c947b9))

### [1.5.2](https://github.com/politics-rewired/switchboard/compare/v1.5.1...v1.5.2) (2020-09-22)


### Bug Fixes

* throw error if no order is created ([#148](https://github.com/politics-rewired/switchboard/issues/148)) ([e04a666](https://github.com/politics-rewired/switchboard/commit/e04a6661596825a67195ec9ffb33ad572dc327ee))
* **process-message:** dont wrap in transaction ([4c99941](https://github.com/politics-rewired/switchboard/commit/4c999412afc8d2783b69f995386a9987734acf77))

### [1.5.1](https://github.com/politics-rewired/switchboard/compare/v1.5.0...v1.5.1) (2020-09-20)

## [1.5.0](https://github.com/politics-rewired/switchboard/compare/v1.4.0...v1.5.0) (2020-09-20)


### Features

* **fresh_phone_commitments:** remove truncated day ([#143](https://github.com/politics-rewired/switchboard/issues/143)) ([f195f23](https://github.com/politics-rewired/switchboard/commit/f195f2364550ba99512302d1d585ee0e16c4422a))
* **phone-commitments:** bring back with for update skip locked ([#135](https://github.com/politics-rewired/switchboard/issues/135)) ([2427c68](https://github.com/politics-rewired/switchboard/commit/2427c6835f86aad2727c3edb2efd8c91854de575))
* **process-message:** break out into js w/ timing ([#138](https://github.com/politics-rewired/switchboard/issues/138)) ([b0684ab](https://github.com/politics-rewired/switchboard/commit/b0684ab6ed9e7cd7e36ad6df2d10fbd532a5a5f9))
* **worker:** control jobs to run with envvar ([#142](https://github.com/politics-rewired/switchboard/issues/142)) ([ceb2ff1](https://github.com/politics-rewired/switchboard/commit/ceb2ff1b8733f90681393e1cf282185e131ef7bb))

## [1.4.0](https://github.com/politics-rewired/switchboard/compare/v1.3.0...v1.4.0) (2020-09-17)


### Features

* **process-message:** add statsd logs ([#137](https://github.com/politics-rewired/switchboard/issues/137)) ([930b606](https://github.com/politics-rewired/switchboard/commit/930b606ae606872e8f1d3bb7ec9b2285b1832c62))

## [1.3.0](https://github.com/politics-rewired/switchboard/compare/v1.2.0...v1.3.0) (2020-09-16)


### Features

* **phone-mappings:** deprecate fresh_phone_commitments ([#133](https://github.com/politics-rewired/switchboard/issues/133)) ([9c1b736](https://github.com/politics-rewired/switchboard/commit/9c1b73642216bc9b62b0b69a76c176445d749fab))
* **process-message:** post metrics ([#136](https://github.com/politics-rewired/switchboard/issues/136)) ([f36e797](https://github.com/politics-rewired/switchboard/commit/f36e79706e7e06cc23ad8172545530364215751f))

## [1.2.0](https://github.com/politics-rewired/switchboard/compare/v0.1.10...v1.2.0) (2020-09-15)


### Features

* **outbound_messages:** record cost of sent messages ([#124](https://github.com/politics-rewired/switchboard/issues/124)) ([82f8802](https://github.com/politics-rewired/switchboard/commit/82f880205ac4f2748b9073b86db4a4da84e1a6e9))
* **purchase-number:** support voice urls ([#127](https://github.com/politics-rewired/switchboard/issues/127)) ([1fdbe2d](https://github.com/politics-rewired/switchboard/commit/1fdbe2dbac7a992c5196e5df132513a415db7326))
* **sending_locations:** add activePhoneNumberCount computed column ([#126](https://github.com/politics-rewired/switchboard/issues/126)) ([926c6b0](https://github.com/politics-rewired/switchboard/commit/926c6b0b89de9d588b057c918722150db67010f1))
* backfill replies script ([db0a20c](https://github.com/politics-rewired/switchboard/commit/db0a20cea915a88dc754548629666d9994fb2f37))
* twilio sell all numbers script ([0d64c72](https://github.com/politics-rewired/switchboard/commit/0d64c72c6aa72ce4dafd45b214d54b08144d70ed))


### Bug Fixes

* **poll-number-order:** fall back on phone number status ([#131](https://github.com/politics-rewired/switchboard/issues/131)) ([ca53e69](https://github.com/politics-rewired/switchboard/commit/ca53e692193b45b01b21a643678f8d99f9dc7d93))
* **replies:** ignore inbound short-code messages ([#129](https://github.com/politics-rewired/switchboard/issues/129)) ([3ab0046](https://github.com/politics-rewired/switchboard/commit/3ab004610594ed312d18f7d23b42d8cdf33a1dff))
* handle null telnyx cost property ([#128](https://github.com/politics-rewired/switchboard/issues/128)) ([58a783d](https://github.com/politics-rewired/switchboard/commit/58a783d3f6892e7984bccd3da406c34a54c0070c))
* verify that delete requests succeeded ([#123](https://github.com/politics-rewired/switchboard/issues/123)) ([95b3f4c](https://github.com/politics-rewired/switchboard/commit/95b3f4ccbb3530b94e3c6e4e94259bf620a10011))

## [1.1.0](https://github.com/politics-rewired/switchboard/compare/v1.0.1...v1.1.0) (2020-09-08)


### Features

* **sending_locations:** add activePhoneNumberCount computed column ([#126](https://github.com/politics-rewired/switchboard/issues/126)) ([926c6b0](https://github.com/politics-rewired/switchboard/commit/926c6b0b89de9d588b057c918722150db67010f1))


### Bug Fixes

* **replies:** ignore inbound short-code messages ([#129](https://github.com/politics-rewired/switchboard/issues/129)) ([3ab0046](https://github.com/politics-rewired/switchboard/commit/3ab004610594ed312d18f7d23b42d8cdf33a1dff))

### [1.0.1](https://github.com/politics-rewired/switchboard/compare/v1.0.0...v1.0.1) (2020-09-08)


### Bug Fixes

* handle null telnyx cost property ([#128](https://github.com/politics-rewired/switchboard/issues/128)) ([58a783d](https://github.com/politics-rewired/switchboard/commit/58a783d3f6892e7984bccd3da406c34a54c0070c))

## [1.0.0](https://github.com/politics-rewired/switchboard/compare/v0.1.10...v1.0.0) (2020-09-07)


### Features

* **outbound_messages:** record cost of sent messages ([#124](https://github.com/politics-rewired/switchboard/issues/124)) ([82f8802](https://github.com/politics-rewired/switchboard/commit/82f880205ac4f2748b9073b86db4a4da84e1a6e9))
* **purchase-number:** support voice urls ([#127](https://github.com/politics-rewired/switchboard/issues/127)) ([1fdbe2d](https://github.com/politics-rewired/switchboard/commit/1fdbe2dbac7a992c5196e5df132513a415db7326))
* backfill replies script ([db0a20c](https://github.com/politics-rewired/switchboard/commit/db0a20cea915a88dc754548629666d9994fb2f37))
* twilio sell all numbers script ([0d64c72](https://github.com/politics-rewired/switchboard/commit/0d64c72c6aa72ce4dafd45b214d54b08144d70ed))


### Bug Fixes

* verify that delete requests succeeded ([#123](https://github.com/politics-rewired/switchboard/issues/123)) ([95b3f4c](https://github.com/politics-rewired/switchboard/commit/95b3f4ccbb3530b94e3c6e4e94259bf620a10011))

### [0.1.10](https://github.com/politics-rewired/switchboard/compare/v0.1.9...v0.1.10) (2020-07-07)


### Bug Fixes

* await purchaseNumberTelnyx ([0cce9d5](https://github.com/politics-rewired/switchboard/commit/0cce9d53cffd2dcee8adebd60364d3a6dcd757c8))
* handle case when telnyx number is no longer available ([a7557e0](https://github.com/politics-rewired/switchboard/commit/a7557e0308c96ef947bda77cc7b6715666fbc95f))
* throw error for no matching numbers ([2e9a742](https://github.com/politics-rewired/switchboard/commit/2e9a742fcd97325fa71eb89a07baab10fd5ae531))

### [0.1.9](https://github.com/politics-rewired/switchboard/compare/v0.1.8...v0.1.9) (2020-07-07)


### Features

* use jobs to poll for telnyx number order completion ([#122](https://github.com/politics-rewired/switchboard/issues/122)) ([3686e05](https://github.com/politics-rewired/switchboard/commit/3686e0573999f2426c87b4ca8ae1642777f1e6d4))

### [0.1.8](https://github.com/politics-rewired/switchboard/compare/v0.1.7...v0.1.8) (2020-07-03)


### Bug Fixes

* forward delivery report extra ([#120](https://github.com/politics-rewired/switchboard/issues/120)) ([f482aae](https://github.com/politics-rewired/switchboard/commit/f482aae8cc073ec4093a06ad2a657fc1de92788a))

### [0.1.7](https://github.com/politics-rewired/switchboard/compare/v0.1.6...v0.1.7) (2020-07-02)


### Features

* handle twilio invalid destination number ([af17934](https://github.com/politics-rewired/switchboard/commit/af1793451c8caca877d9c4e9d9e9b625f77d9bec))
* **purchase-number:** find a new suitable area code on failure ([#118](https://github.com/politics-rewired/switchboard/issues/118)) ([ca35774](https://github.com/politics-rewired/switchboard/commit/ca35774d1368875812a4cf46b336a277f6198411))


### Bug Fixes

* switch up and down migrations ([0d090e1](https://github.com/politics-rewired/switchboard/commit/0d090e1521b3ef6758029e1da227ccae8d4f67b1))

### [0.1.6](https://github.com/politics-rewired/switchboard/compare/v0.1.5...v0.1.6) (2020-06-28)


### Features

* handle known sendMessage error codes ([#116](https://github.com/politics-rewired/switchboard/issues/116)) ([9e06abd](https://github.com/politics-rewired/switchboard/commit/9e06abd1fb94c88797b0ff76a74222f5a262319a))
* send delivery report on service sent ([#117](https://github.com/politics-rewired/switchboard/issues/117)) ([ea856ae](https://github.com/politics-rewired/switchboard/commit/ea856aef7566f54b2991a6e1ea81067a4e4d9c59))

### [0.1.5](https://github.com/politics-rewired/switchboard/compare/v0.1.4...v0.1.5) (2020-06-27)


### Features

* **pending_number_request_capacity:** cache commitment counts ([#107](https://github.com/politics-rewired/switchboard/issues/107)) ([82aa73f](https://github.com/politics-rewired/switchboard/commit/82aa73f10d14106376ac82fe011f429af904d781))


### Bug Fixes

* accept url shortener domain option ([c332156](https://github.com/politics-rewired/switchboard/commit/c33215662b6a2618fa21609e2275daff5912a6f5))
* ensure sending locations have area codes ([#114](https://github.com/politics-rewired/switchboard/issues/114)) ([4b73407](https://github.com/politics-rewired/switchboard/commit/4b73407c02adaa4ce53b3935a2806df7715b8811))
* handle case where to is array ([d23b96e](https://github.com/politics-rewired/switchboard/commit/d23b96e0df5ac0a83501330fff92276dde069c1f))
* log the complete error with context ([#106](https://github.com/politics-rewired/switchboard/issues/106)) ([a1ce97a](https://github.com/politics-rewired/switchboard/commit/a1ce97a7d69b09e68ec2260445dede6e47a80494))
* prevent divide by zero error in lookup progress ([#112](https://github.com/politics-rewired/switchboard/issues/112)) ([4df50c7](https://github.com/politics-rewired/switchboard/commit/4df50c7961dd1dc18c62052e262a6cdb21026751))
* select the nearest sending locations ([#113](https://github.com/politics-rewired/switchboard/issues/113)) ([bb23c5f](https://github.com/politics-rewired/switchboard/commit/bb23c5fbb9e255a23c7bb1c50bc9b7bdd39c6187))

### [0.1.4](https://github.com/politics-rewired/switchboard/compare/v0.1.3...v0.1.4) (2020-06-17)


### Bug Fixes

* convert Errors to objects to log properly ([66026bf](https://github.com/politics-rewired/switchboard/commit/66026bfdf7e238ec8446bff8ef424f2018e43931))

### [0.1.3](https://github.com/politics-rewired/switchboard/compare/v0.1.2...v0.1.3) (2020-06-17)


### Bug Fixes

* reply error handling ([#105](https://github.com/politics-rewired/switchboard/issues/105)) ([a8f4607](https://github.com/politics-rewired/switchboard/commit/a8f460772cd82d5dcc3a6db36e6274c9a54eeb08))
* set url shortener settings ([#104](https://github.com/politics-rewired/switchboard/issues/104)) ([5794bec](https://github.com/politics-rewired/switchboard/commit/5794bec0e9743594ba832ca984eeffb5bb904e93))

### [0.1.2](https://github.com/politics-rewired/switchboard/compare/v0.1.1...v0.1.2) (2020-06-15)

### [0.1.1](https://github.com/politics-rewired/switchboard/compare/v0.1.0...v0.1.1) (2020-06-15)

### Features

- create separate telnyx profiles for each client ([#101](https://github.com/politics-rewired/switchboard/issues/101)) ([0bf23fa](https://github.com/politics-rewired/switchboard/commit/0bf23fadcb329b87392e09fc2c6de2f26be2e183))
- **purchase-number:** find a new suitable area code on failure ([#96](https://github.com/politics-rewired/switchboard/issues/96)) ([bbf1191](https://github.com/politics-rewired/switchboard/commit/bbf11918b69c4ca6eebd518edf115bd6c44b3910))

### Bug Fixes

- disable postgraphile query logging ([#102](https://github.com/politics-rewired/switchboard/issues/102)) ([9928318](https://github.com/politics-rewired/switchboard/commit/99283187ba7851f2d9b3bd3e8010237d93ff840c))
- ignore empty addPhoneNumbersToRequest payload ([#95](https://github.com/politics-rewired/switchboard/issues/95)) ([b0868fe](https://github.com/politics-rewired/switchboard/commit/b0868fee210ce224e6cf2eeab3e2e8d8e3dd7014))
