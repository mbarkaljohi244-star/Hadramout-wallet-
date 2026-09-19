---
name: KYC client boundary
description: Scope boundary for the mobile KYC flow while the API has no KYC persistence or document upload contract.
---

The mobile KYC flow can validate and collect the 11-step draft locally, but it must not claim that a submission is persisted until the API exposes authenticated profile submission, protected document upload, and review-status endpoints.

**Why:** The current Node API supports wallet authentication and transfers only; sending sensitive identity documents to an unimplemented endpoint would create a false success state and an unsafe storage path.

**How to apply:** Keep the current completion message explicit about local review flow, then connect the final step to the backend only after the KYC contract and protected storage path are implemented.