import crypto from 'crypto';
import cryptr from 'cryptr';

import config from '../config';

// Decrypts ciphertexts produced by cryptr v4 (aes-256-ctr + SHA-256 key).
// Kept so existing DB credentials and client tokens remain readable after the
// cryptr v6 upgrade, until Phase 2 (DB re-encryption) is complete.
function decryptV4(value: string): string {
  const key = Uint8Array.from(
    crypto.createHash('sha256').update(config.applicationSecret).digest()
  );
  const stringValue = String(value);
  const iv = Uint8Array.from(Buffer.from(stringValue.slice(0, 32), 'hex'));
  const encrypted = stringValue.slice(32);
  let legacyValue = false;
  let decipher: crypto.Decipheriv | undefined;

  try {
    decipher = crypto.createDecipheriv('aes-256-ctr', key, iv);
  } catch (exception: any) {
    if (exception.message === 'Invalid IV length') {
      legacyValue = true;
    } else {
      throw exception;
    }
  }

  if (!legacyValue) {
    return decipher!.update(encrypted, 'hex', 'utf8') + decipher!.final('utf8');
  }

  const legacyIv = Uint8Array.from(
    Buffer.from(stringValue.slice(0, 16), 'hex')
  );
  const legacyEncrypted = stringValue.slice(16);
  const legacyDecipher = crypto.createDecipheriv('aes-256-ctr', key, legacyIv);
  return (
    legacyDecipher.update(legacyEncrypted, 'hex', 'utf8') +
    legacyDecipher.final('utf8')
  );
}

const cryptV6 = new cryptr(config.applicationSecret);

export const crypt = {
  encrypt: (value: string) => cryptV6.encrypt(value),
  decrypt: (value: string): string => {
    try {
      return cryptV6.decrypt(value);
    } catch {
      return decryptV4(value);
    }
  },
};
