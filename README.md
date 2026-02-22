# IntentLock Wallet

A smart contract-based intent wallet system built on Clarity for secure, time-bound transaction execution.

## Overview

**IntentLock Wallet** is a core smart wallet contract that enables intent-based transactions with expiration controls. Users can create intents specifying a recipient, amount, and expiration block height. These intents can only be executed within their valid time window and prevent replay attacks through execution tracking.

## Features

- **Intent Creation**: Define transfer intents with recipient, amount, and expiration
- **Time-Bound Execution**: Intents expire after a specified block height
- **Replay Protection**: Each intent can only be executed once
- **Owner Authorization**: Only the wallet owner can create intents
- **Intent Validation**: Query intent status and verify execution eligibility

## Key Functions

| Function | Purpose |
|----------|---------|
| `create-intent` | Create a new transfer intent |
| `execute-intent` | Execute and mark an intent as completed |
| `get-intent` | Retrieve intent details |
| `intent-valid?` | Check if an intent is still executable |

## Error Codes

- `ERR-NOT-OWNER (11001)`: Caller is not the wallet owner
- `ERR-INTENT-NOT-FOUND (11002)`: Intent ID does not exist
- `ERR-INTENT-EXPIRED (11003)`: Intent has passed its expiration block
- `ERR-ALREADY-USED (11004)`: Intent has already been executed
- `ERR-INVALID-AMOUNT (11005)`: Amount must be greater than zero
- `ERR-INVALID-EXPIRY (11006)`: Expiration must be in the future

## Architecture Note

This contract enforces intent correctness and authorization. Actual STX transfers are delegated to a separate vault contract for enhanced security and flexibility.
