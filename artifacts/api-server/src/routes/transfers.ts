import { randomUUID } from "node:crypto";
import { asc, eq, inArray, sql } from "drizzle-orm";
import { Router, type IRouter } from "express";
import { db, usersTable, type User } from "@workspace/db";
import {
  TransferFundsBody,
  TransferFundsResponse,
  type TransferResult,
} from "@workspace/api-zod";

const router: IRouter = Router();
const DECIMAL_SCALE = 100_000_000;

type TransferFailure = {
  ok: false;
  status: 400 | 404 | 409;
  error: string;
};

type TransferSuccess = {
  ok: true;
  data: TransferResult;
};

type TransferOutcome = TransferFailure | TransferSuccess;

const isValidAmount = (amount: number): boolean => {
  const scaledAmount = amount * DECIMAL_SCALE;
  const roundedAmount = Math.round(scaledAmount);

  return (
    Number.isFinite(amount) &&
    amount > 0 &&
    Number.isSafeInteger(roundedAmount) &&
    Math.abs(scaledAmount - roundedAmount) < 0.000001
  );
};

const roundAmount = (amount: number): number =>
  Math.round(amount * DECIMAL_SCALE) / DECIMAL_SCALE;

const getBalance = (user: User, currency: string): number => {
  switch (currency) {
    case "YER":
      return Number(user.yerBalance);
    case "SAR":
      return Number(user.sarBalance);
    case "USD":
      return Number(user.usdBalance);
    case "USDT":
      return Number(user.usdtBalance);
    default:
      return Number.NaN;
  }
};

const updateBalance = async (
  tx: Parameters<Parameters<typeof db.transaction>[0]>[0],
  walletId: string,
  currency: string,
  delta: number,
): Promise<void> => {
  switch (currency) {
    case "YER":
      await tx
        .update(usersTable)
        .set({
          yerBalance: sql`${usersTable.yerBalance} + ${delta}`,
        })
        .where(eq(usersTable.walletId, walletId));
      return;
    case "SAR":
      await tx
        .update(usersTable)
        .set({
          sarBalance: sql`${usersTable.sarBalance} + ${delta}`,
        })
        .where(eq(usersTable.walletId, walletId));
      return;
    case "USD":
      await tx
        .update(usersTable)
        .set({
          usdBalance: sql`${usersTable.usdBalance} + ${delta}`,
        })
        .where(eq(usersTable.walletId, walletId));
      return;
    case "USDT":
      await tx
        .update(usersTable)
        .set({
          usdtBalance: sql`${usersTable.usdtBalance} + ${delta}`,
        })
        .where(eq(usersTable.walletId, walletId));
      return;
  }
};

router.post("/transfer", async (req, res) => {
  const parsedRequest = TransferFundsBody.strict().safeParse(req.body);

  if (!parsedRequest.success) {
    res.status(400).json({ error: "Invalid transfer details" });
    return;
  }

  const {
    senderWalletId,
    receiverWalletId,
    amount,
    currency,
  } = parsedRequest.data;

  if (!isValidAmount(amount)) {
    res
      .status(400)
      .json({ error: "Amount must be positive and use at most 8 decimals" });
    return;
  }

  if (senderWalletId === receiverWalletId) {
    res
      .status(400)
      .json({ error: "Sender and receiver wallets must be different" });
    return;
  }

  try {
    const outcome = await db.transaction(async (tx): Promise<TransferOutcome> => {
      const walletIds = [senderWalletId, receiverWalletId].sort();
      const lockedUsers = await tx
        .select()
        .from(usersTable)
        .where(inArray(usersTable.walletId, walletIds))
        .orderBy(asc(usersTable.walletId))
        .for("update");

      const sender = lockedUsers.find(
        (user) => user.walletId === senderWalletId,
      );
      const receiver = lockedUsers.find(
        (user) => user.walletId === receiverWalletId,
      );

      if (!sender || !receiver) {
        return {
          ok: false,
          status: 404,
          error: "Sender or receiver wallet was not found",
        };
      }

      const senderBalance = getBalance(sender, currency);

      if (senderBalance < amount) {
        return {
          ok: false,
          status: 409,
          error: "Insufficient funds",
        };
      }

      await updateBalance(tx, senderWalletId, currency, -amount);
      await updateBalance(tx, receiverWalletId, currency, amount);

      return {
        ok: true,
        data: {
          transferId: randomUUID(),
          senderWalletId,
          receiverWalletId,
          amount,
          currency,
          senderBalance: roundAmount(senderBalance - amount),
          receiverBalance: roundAmount(getBalance(receiver, currency) + amount),
          transferredAt: new Date(),
        },
      };
    });

    if (!outcome.ok) {
      res.status(outcome.status).json({ error: outcome.error });
      return;
    }

    req.log.info(
      {
        senderWalletId,
        receiverWalletId,
        currency,
        amount,
        transferId: outcome.data.transferId,
      },
      "Funds transferred",
    );
    res.status(200).json(TransferFundsResponse.parse(outcome.data));
  } catch (error) {
    req.log.error(
      { err: error, senderWalletId, receiverWalletId, currency },
      "Unable to transfer funds",
    );
    res.status(503).json({ error: "Unable to complete the transfer right now" });
  }
});

export default router;