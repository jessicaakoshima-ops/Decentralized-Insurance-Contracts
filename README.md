# 🛡️ Decentralized Insurance Contracts

A trustless, blockchain-based insurance platform built on the Stacks blockchain using Clarity smart contracts. This decentralized insurance system allows users to create policies, file claims, and manage payouts without intermediaries.

## 📋 Overview

This smart contract implements a complete decentralized insurance system featuring:

- **Policy Creation**: Users can purchase insurance policies with custom premiums, coverage amounts, and durations
- **Claims Management**: Policyholders can file claims against their active policies
- **Claim Approval/Rejection**: Contract owner can review and approve or reject pending claims
- **Insurance Pool**: Premiums are pooled together to fund approved claims
- **Transparency**: All policies, claims, and transactions are recorded on-chain

## ✨ Features

- 💰 **Flexible Policy Creation** - Set your own premium, coverage, and duration
- 📝 **Claim Filing** - File claims up to your coverage amount
- ✅ **Claim Processing** - Owner-managed approval/rejection system
- 🔒 **Security** - Built-in authorization and validation checks
- 📊 **Statistics** - Track pool balance, total premiums, and payouts
- 👤 **User Dashboard** - View all policies associated with your account
- ⏱️ **Time-based Expiry** - Policies expire after specified duration

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic understanding of Clarity and Stacks blockchain

### Installation

```bash
git clone <your-repo-url>
cd Decentralized-Insurance-Contracts
clarinet check
```

### Running Tests

```bash
npm install
npm test
```

## 📖 Usage

### Creating a Policy

Create an insurance policy by paying a premium:

```clarity
(contract-call? .Decentralized-Insurance-Contracts create-policy u1000000 u5000000 u1000)
```

**Parameters:**
- `premium` (uint): Amount to pay in microSTX
- `coverage` (uint): Maximum claim amount in microSTX
- `duration` (uint): Policy duration in blocks

**Returns:** Policy ID

### Filing a Claim

File a claim against your active policy:

```clarity
(contract-call? .Decentralized-Insurance-Contracts file-claim u1 u2000000)
```

**Parameters:**
- `policy-id` (uint): Your policy ID
- `claim-amount` (uint): Amount to claim in microSTX

**Returns:** Claim ID

### Approving a Claim (Owner Only)

Contract owner approves a pending claim:

```clarity
(contract-call? .Decentralized-Insurance-Contracts approve-claim u1)
```

**Parameters:**
- `claim-id` (uint): ID of the claim to approve

### Rejecting a Claim (Owner Only)

Contract owner rejects a pending claim:

```clarity
(contract-call? .Decentralized-Insurance-Contracts reject-claim u1)
```

**Parameters:**
- `claim-id` (uint): ID of the claim to reject

### Canceling a Policy

Policy holder can cancel their active policy:

```clarity
(contract-call? .Decentralized-Insurance-Contracts cancel-policy u1)
```

**Parameters:**
- `policy-id` (uint): ID of the policy to cancel

## 🔍 Read-Only Functions

### Get Policy Details

```clarity
(contract-call? .Decentralized-Insurance-Contracts get-policy u1)
```

Returns policy information including holder, premium, coverage, start/end blocks, and active status.

### Get Claim Details

```clarity
(contract-call? .Decentralized-Insurance-Contracts get-claim u1)
```

Returns claim information including policy ID, claimant, amount, status, and filed block.

### Get User Policies

```clarity
(contract-call? .Decentralized-Insurance-Contracts get-user-policies 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

Returns list of all policy IDs for a given user.

### Get Pool Balance

```clarity
(contract-call? .Decentralized-Insurance-Contracts get-pool-balance)
```

Returns current insurance pool balance.

### Get Policy Status

```clarity
(contract-call? .Decentralized-Insurance-Contracts get-policy-status u1)
```

Returns active status, expiration status, and remaining blocks for a policy.

### Get Contract Statistics

```clarity
(contract-call? .Decentralized-Insurance-Contracts get-contract-stats)
```

Returns total policies, claims, pool balance, total premiums collected, and total payouts.

## 🛠️ Contract Structure

### Data Maps

- `policies` - Stores all insurance policies
- `claims` - Stores all filed claims
- `user-policies` - Maps users to their policy IDs

### Data Variables

- `policy-counter` - Tracks total policies created
- `claim-counter` - Tracks total claims filed
- `pool-balance` - Current insurance pool balance
- `total-premiums` - Lifetime premiums collected
- `total-payouts` - Lifetime payouts made

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | err-owner-only | Action requires contract owner |
| u101 | err-not-found | Policy or claim not found |
| u102 | err-already-exists | Entity already exists |
| u103 | err-insufficient-funds | Insufficient pool balance |
| u104 | err-policy-expired | Policy has expired |
| u105 | err-policy-not-active | Policy is not active |
| u106 | err-claim-already-exists | Claim already exists |
| u107 | err-claim-not-pending | Claim is not in pending status |
| u108 | err-invalid-amount | Invalid amount specified |
| u109 | err-invalid-duration | Invalid duration specified |
| u110 | err-unauthorized | Unauthorized access |

## 💡 Example Workflow

1. **User purchases policy**
   ```clarity
   (create-policy u500000 u2000000 u500)
   ;; Returns: (ok u1)
   ```

2. **User experiences insured event and files claim**
   ```clarity
   (file-claim u1 u1500000)
   ;; Returns: (ok u1)
   ```

3. **Owner reviews and approves claim**
   ```clarity
   (approve-claim u1)
   ;; Returns: (ok true)
   ;; User receives 1.5 STX, policy becomes inactive
   ```

## ⚠️ Important Notes

- Coverage amount must be greater than or equal to premium
- Claims can only be filed on active, non-expired policies
- Approved claims automatically deactivate the associated policy
- Only the contract owner can approve or reject claims
- All amounts are in microSTX (1 STX = 1,000,000 microSTX)
- Block height referenced as `stacks-block-height` (Clarity 2.0+)

## 🔐 Security Considerations

- Authorization checks ensure only policy holders can file claims on their policies
- Owner privileges are restricted to claim approval/rejection
- All transfers are protected by try! and unwrap! error handling
- Pool balance is tracked to prevent over-distribution
- Policies have time-based expiration to limit exposure

## 📜 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For questions or issues, please open an issue on GitHub.

---

Built with ❤️ on Stacks

