import crypto from 'crypto';
import cryptr from 'cryptr';

import config from '../config';

// Decrypts ciphertexts produced by cryptr v4 (aes-256-ctr + SHA-256 key).
// Kept so existing DB credentials and client tokens remain readable after the
// cryptr v6 upgrade, until Phase 2 (DB re-encryption) is complete.
function decryptV4(value: string): string {
  const key = crypto
    .createHash('sha256')
    .update(config.applicationSecret)
    .digest();
  const iv = Buffer.from(value.slice(0, 32), 'hex');
  const encrypted = value.slice(32);
  const decipher = crypto.createDecipheriv('aes-256-ctr', key, iv);
  return decipher.update(encrypted, 'hex', 'utf8') + decipher.final('utf8');
}

const cryptV6 = new cryptr(config.applicationSecret);

export const crypt = {
  encrypt: (value: string) => cryptV6.encrypt(value),
  decrypt: (value: string): string => {
    try {
      return cryptV6.decrypt(value);
    } catch (err: any) {
      if (err?.message?.includes('unable to authenticate data')) {
        throw err;
      }
      return decryptV4(value);
    }
  },
};
