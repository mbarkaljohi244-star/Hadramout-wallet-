---
name: Wallet authentication model
description: Durable authentication boundary for wallet credentials, JWTs, PINs, and optional managed Clerk identities.
---

Wallet authentication keeps local wallet credentials authoritative for API access: passwords issue signed local JWTs, and the six-digit PIN can authorize a transfer when no JWT is supplied. A managed Clerk identity may be linked to a wallet and can authorize only that linked wallet.

**Why:** The product requires password login, a transfer PIN, and API-level JWT/PIN enforcement while Replit-managed Clerk provides the platform identity/session layer.

**How to apply:** Keep password and PIN values as salted scrypt-derived hashes only. Any new money-moving endpoint must require a wallet-owning local JWT, a linked Clerk identity, or a verified wallet PIN before changing balances.