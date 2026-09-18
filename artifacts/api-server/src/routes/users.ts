import { randomInt } from "node:crypto";
import { Router, type IRouter } from "express";
import {
  db,
  usersTable,
  type NewUser,
  type User,
} from "@workspace/db";
import {
  RegisterUserBody,
  RegisterUserResponse,
  type WalletRegistrationResponse,
} from "@workspace/api-zod";

const router: IRouter = Router();
const MAX_WALLET_ID_ATTEMPTS = 10;

const createWalletId = (): string =>
  `HW-${randomInt(0, 1_000_000).toString().padStart(6, "0")}`;

const isUniqueViolation = (error: unknown): boolean =>
  typeof error === "object" &&
  error !== null &&
  "code" in error &&
  error.code === "23505";

const createUser = async (
  name: string | undefined,
  email: string | undefined,
): Promise<User> => {
  for (let attempt = 0; attempt < MAX_WALLET_ID_ATTEMPTS; attempt += 1) {
    const values: NewUser = {
      walletId: createWalletId(),
      ...(name ? { name } : {}),
      ...(email ? { email } : {}),
    };

    try {
      const [user] = await db.insert(usersTable).values(values).returning();

      if (!user) {
        throw new Error("User insert did not return a row");
      }

      return user;
    } catch (error) {
      if (!isUniqueViolation(error)) {
        throw error;
      }
    }
  }

  throw new Error("Unable to allocate a unique wallet ID");
};

const toRegistrationResponse = (
  user: User,
): WalletRegistrationResponse =>
  RegisterUserResponse.parse({
    userId: user.userId,
    walletId: user.walletId,
    ...(user.name ? { name: user.name } : {}),
    ...(user.email ? { email: user.email } : {}),
    balances: {
      YER: 0,
      SAR: 0,
      USD: 0,
      USDT: 0,
    },
    createdAt: user.createdAt,
  });

router.post("/users/register", async (req, res) => {
  const parsedRequest = RegisterUserBody.strict().safeParse(req.body ?? {});

  if (!parsedRequest.success) {
    res.status(400).json({ error: "Invalid registration details" });
    return;
  }

  try {
    const user = await createUser(
      parsedRequest.data.name,
      parsedRequest.data.email,
    );
    const response = toRegistrationResponse(user);

    req.log.info({ walletId: user.walletId }, "User registered");
    res.status(201).json(response);
  } catch (error) {
    req.log.error({ err: error }, "Unable to register user");
    res.status(503).json({ error: "Unable to create a wallet right now" });
  }
});

export default router;