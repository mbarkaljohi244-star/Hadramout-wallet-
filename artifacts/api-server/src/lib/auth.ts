import {
  createHmac,
  randomBytes,
  scrypt as scryptCallback,
  timingSafeEqual,
} from "node:crypto";
import type { Request } from "express";
import { getAuth } from "@clerk/express";

const JWT_ALGORITHM = "HS256";
const JWT_TTL_SECONDS = 60 * 60 * 24 * 7;
const SCRYPT_KEY_LENGTH = 64;

const sessionSecret = process.env.SESSION_SECRET;

if (!sessionSecret) {
  throw new Error("SESSION_SECRET must be configured for wallet authentication");
}

type JwtPayload = {
  sub: string;
  iat: number;
  exp: number;
};

const deriveKey = (credential: string, salt: string): Promise<Buffer> =>
  new Promise((resolve, reject) => {
    scryptCallback(
      credential,
      salt,
      SCRYPT_KEY_LENGTH,
      { N: 16_384, r: 8, p: 1 },
      (error, derivedKey) => {
        if (error) {
          reject(error);
          return;
        }

        resolve(derivedKey as Buffer);
      },
    );
  });

export type RequestIdentity =
  | { kind: "jwt"; userId: string }
  | { kind: "clerk"; clerkUserId: string };

const encodeBase64Url = (value: string | Buffer): string =>
  Buffer.from(value).toString("base64url");

const decodeBase64Url = (value: string): string =>
  Buffer.from(value, "base64url").toString("utf8");

const sign = (value: string): string =>
  createHmac("sha256", sessionSecret).update(value).digest("base64url");

export const hashCredential = async (
  credential: string,
): Promise<{ hash: string; salt: string }> => {
  const salt = randomBytes(32).toString("base64url");
  const derivedKey = await deriveKey(credential, salt);

  return {
    hash: derivedKey.toString("base64url"),
    salt,
  };
};

export const verifyCredential = async (
  credential: string,
  hash: string,
  salt: string,
): Promise<boolean> => {
  const derivedKey = await deriveKey(credential, salt);
  const expectedHash = Buffer.from(hash, "base64url");

  return (
    derivedKey.length === expectedHash.length &&
    timingSafeEqual(derivedKey, expectedHash)
  );
};

export const createAccessToken = (userId: string): string => {
  const now = Math.floor(Date.now() / 1000);
  const payload: JwtPayload = {
    sub: userId,
    iat: now,
    exp: now + JWT_TTL_SECONDS,
  };
  const header = encodeBase64Url(
    JSON.stringify({ alg: JWT_ALGORITHM, typ: "JWT" }),
  );
  const encodedPayload = encodeBase64Url(JSON.stringify(payload));
  const unsignedToken = `${header}.${encodedPayload}`;

  return `${unsignedToken}.${sign(unsignedToken)}`;
};

export const verifyAccessToken = (token: string): string | null => {
  const parts = token.split(".");

  if (parts.length !== 3) {
    return null;
  }

  const [header, encodedPayload, encodedSignature] = parts;
  const signedValue = `${header}.${encodedPayload}`;
  const expectedSignature = Buffer.from(sign(signedValue), "base64url");
  const providedSignature = Buffer.from(encodedSignature, "base64url");

  if (
    expectedSignature.length !== providedSignature.length ||
    !timingSafeEqual(expectedSignature, providedSignature)
  ) {
    return null;
  }

  try {
    const parsedHeader = JSON.parse(decodeBase64Url(header)) as {
      alg?: unknown;
      typ?: unknown;
    };
    const payload = JSON.parse(decodeBase64Url(encodedPayload)) as Partial<JwtPayload>;

    if (
      parsedHeader.alg !== JWT_ALGORITHM ||
      parsedHeader.typ !== "JWT" ||
      typeof payload.sub !== "string" ||
      typeof payload.exp !== "number" ||
      payload.exp <= Math.floor(Date.now() / 1000)
    ) {
      return null;
    }

    return payload.sub;
  } catch {
    return null;
  }
};

export const getBearerToken = (req: Request): string | null => {
  const authorization = req.headers.authorization;

  if (!authorization?.startsWith("Bearer ")) {
    return null;
  }

  return authorization.slice("Bearer ".length).trim() || null;
};

export const getRequestIdentity = (req: Request): RequestIdentity | null => {
  const bearerToken = getBearerToken(req);
  const localUserId = bearerToken ? verifyAccessToken(bearerToken) : null;

  if (localUserId) {
    return { kind: "jwt", userId: localUserId };
  }

  const clerkUserId = getAuth(req).userId;

  return clerkUserId ? { kind: "clerk", clerkUserId } : null;
};

export const getClerkUserId = (req: Request): string | null =>
  getAuth(req).userId ?? null;