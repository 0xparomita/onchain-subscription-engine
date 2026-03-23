# On-Chain Subscription Engine

A professional-grade framework for recurring payments in DeFi. This repository implements a "Pull-Payment" architecture where users grant a specific allowance to the contract, enabling a service provider to withdraw a fixed amount at defined intervals (e.g., monthly).

## Core Features
* **Recurring Billing:** Automated interval checking to prevent premature billing.
* **User Control:** Users can cancel their subscription at any time by revoking the contract's authority.
* **ERC-20 Compatibility:** Works with any standard stablecoin (USDC, USDT, DAI).
* **Flat Structure:** Optimized for clean deployment and easy integration into dApp frontends.

## Workflow
1. **Subscribe:** User calls `createSubscription`, authorizing the monthly rate.
2. **Charge:** The Provider (or a Keeper bot) calls `executePayment` every 30 days.
3. **Validate:** The contract ensures the time interval has passed and the user has sufficient allowance.

## Setup
1. `npm install`
2. Deploy `SubscriptionEngine.sol`.
3. Use the provided scripts to simulate a 3-month billing cycle.
