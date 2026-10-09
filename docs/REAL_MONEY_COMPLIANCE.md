# Prerequisites for Enabling Live Real-Money Functionality — RealCash

Before enabling live financial payment gateways or real-money wagering in production, the following legal, technical, and regulatory requirements **MUST** be satisfied:

---

## 1. Regulatory Gaming License
- Obtain an official Gambling/Gaming License from authorized regulatory authorities (e.g., Curacao eGaming, UK Gaming Commission, or relevant State Sports Authority).

## 2. Identity Verification & KYC Integration
- Connect an accredited KYC service (e.g., SumSub, Onfido, or Aadhaar/PAN API) to verify player age (18+), identity, and residential jurisdiction.

## 3. Licensed Sports Data Provider
- Replace demonstration sports odds feeds with a licensed real-time sports odds API (e.g., Sportradar, Betgenius, or Oddspedia).

## 4. Payment Gateway Licensing
- Integrate PCI-DSS compliant payment gateways (such as Razorpay, Paytm, Cashfree, or Stripe) with automated webhooks and cryptographic signature verification.

## 5. Security & Third-Party Audit
- Complete an independent penetration test and smart contract / random number generator (RNG) certification audit (e.g., iTech Labs, GLI).
