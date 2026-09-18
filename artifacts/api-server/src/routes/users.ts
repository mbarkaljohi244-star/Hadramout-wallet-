import { randomInt, randomUUID } from "node:crypto";
import { Router, type IRouter } from "express";
import {
  RegisterUserBody,
  RegisterUserResponse,
  type WalletRegistrationResponse,
} from "@workspace/api-zod";

const router: IRouter = Router();
const issuedWalletIds = new Set<string>();
const MAX_WALLET_ID_ATTEMPTS = 10;

const createWalletId = (): string => {
  for (let attempt = 0; attempt < MAX_WALLET_ID_ATTEMPTS; attempt += 1) {
    const walletId = `HW-${randomInt(0, 1_000_000).toString().padStart(6, "0")}`;

    if (!issuedWalletIds.has(walletId)) {
      issuedWalletIds.add(walletId);
      return walletId;
    }
  }

  throw new Error("Unable to allocate a unique wallet ID");
};

router.post("/users/register", (req, res) => {
  const parsedRequest = RegisterUserBody.strict().safeParse(req.body ?? {});

  if (!parsedRequest.success) {
    res.status(400).json({ error: "Invalid registration details" });
    return;
  }

  let walletId: string;

  try {
    walletId = createWalletId();
  } catch (error) {
    req.log.error({ err: error }, "Unable to allocate a wallet ID");
    res.status(503).json({ error: "Unable to create a wallet right now" });
    return;
  }

  const { name, email } = parsedRequest.data;
  const response: WalletRegistrationResponse = {
    userId: randomUUID(),
    walletId,
    ...(name ? { name } : {}),
    ...(email ? { email } : {}),
    balances: {
      YER: 0,
      SAR: 0,
      USD: 0,
      USDT: 0,
    },
    createdAt: new Date(),
  };

  const validatedResponse = RegisterUserResponse.parse(response);
  req.log.info({ walletId }, "User registered");
  res.status(201).json(validatedResponse);
});

export default router;