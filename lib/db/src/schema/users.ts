import {
  numeric,
  pgTable,
  timestamp,
  uuid,
  varchar,
} from "drizzle-orm/pg-core";

export const usersTable = pgTable("wallet_users", {
  userId: uuid("user_id").primaryKey().defaultRandom(),
  walletId: varchar("wallet_id", { length: 9 }).notNull().unique(),
  clerkUserId: varchar("clerk_user_id", { length: 255 }).unique(),
  name: varchar("name", { length: 100 }),
  email: varchar("email", { length: 254 }),
  passwordHash: varchar("password_hash", { length: 128 }).notNull(),
  passwordSalt: varchar("password_salt", { length: 64 }).notNull(),
  pinHash: varchar("pin_hash", { length: 128 }).notNull(),
  pinSalt: varchar("pin_salt", { length: 64 }).notNull(),
  yerBalance: numeric("yer_balance", { precision: 20, scale: 8 })
    .notNull()
    .default("0"),
  sarBalance: numeric("sar_balance", { precision: 20, scale: 8 })
    .notNull()
    .default("0"),
  usdBalance: numeric("usd_balance", { precision: 20, scale: 8 })
    .notNull()
    .default("0"),
  usdtBalance: numeric("usdt_balance", { precision: 20, scale: 8 })
    .notNull()
    .default("0"),
  createdAt: timestamp("created_at", { withTimezone: true })
    .notNull()
    .defaultNow(),
});

export type User = typeof usersTable.$inferSelect;
export type NewUser = typeof usersTable.$inferInsert;