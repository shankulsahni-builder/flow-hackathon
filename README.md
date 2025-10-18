# Vote & Reward Smart Contract

This project implements a **voting system that rewards participants with tokens** each time they vote.  
It’s designed to be simple, transparent, and educational — showing how governance and token incentives can work together on-chain.

---

## Overview

- **Blockchain:** Flow Testnet  
- **Contract Address:** `0x12448eA4E43D4E9f5BaDd9BEbD5a190BCC01E68b`
- **Language:** Solidity  
- **Features:**  
  - Create proposals  
  - Cast votes (one vote per user per proposal)  
  - Mint token rewards automatically for voters  
  - Adjustable reward amount by contract owner  
  - No constructors, no imports — fully self-contained

---

## Core Functions

| Function | Description |
|-----------|-------------|
| `createProposal(string description)` | Owner creates a new proposal |
| `vote(uint256 proposalId)` | User votes and receives token rewards |
| `setRewardAmount(uint256 newAmount)` | Owner adjusts reward per vote |
| `balanceOf(address account)` | Check token balance |
| `transfer(address to, uint256 amount)` | Transfer tokens |
| `proposalVotes(uint256 proposalId)` | View total votes on a proposal |

---

## Token Details

| Property | Value |
|-----------|--------|
| Name | `VoteToken` |
| Symbol | `VOTE` |
| Decimals | `18` |
| Reward per vote | `10 VOTE` (adjustable by owner) |

---

## Deployed Contract Addresses

| Contract | Network | Address |
|-----------|----------|----------|
| VoteAndReward | Flow Testnet | `0x12448eA4E43D4E9f5BaDd9BEbD5a190BCC01E68b` |

---

## How It Works

1. The contract owner deploys `VoteAndReward`.
2. The owner creates proposals.
3. Any user can vote once per proposal.
4. Each valid vote mints new tokens to the voter’s address.
5. Tokens can be transferred or used as proof of participation.

---

## Notes

- No constructor or import statements are used.
- Ownership is automatically set to the deployer.
- Designed for simplicity and demonstration, not for production use.

---

## License

MIT License © 2025
