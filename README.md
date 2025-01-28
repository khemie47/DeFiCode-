# DeFi Code Review and Rating System Smart Contract

## Overview
A decentralized code review system built on Stacks blockchain that enables secure, transparent evaluation of DeFi projects. The system implements a collateral-based review mechanism where evaluators must stake tokens to participate, ensuring high-quality, accountable feedback.

## Features
- **Code Project Submission**: Developers can submit their projects for review
- **Collateral-Based Evaluation**: Evaluators must stake STX tokens to participate
- **Structured Feedback System**: Standardized rating system with detailed feedback
- **Quality Score Tracking**: Cumulative project quality scoring
- **Secure Collateral Management**: Safe deposit and withdrawal of evaluator stakes

## Contract Details

### Core Functions

#### For Project Developers
- `submit-code-project`: Submit a new project for review
  - Parameters:
    - `project-name`: Project name (max 64 chars)
    - `release-tag`: Version or release tag (max 32 chars)
  - Returns: Unique code ID

#### For Evaluators
- `deposit-evaluator-collateral`: Stake tokens to become an evaluator
  - Parameters:
    - `collateral-amount`: Amount of STX to stake
- `withdraw-evaluator-collateral`: Withdraw staked collateral
  - Parameters:
    - `withdraw-amount`: Amount of STX to withdraw
- `submit-code-feedback`: Submit project review
  - Parameters:
    - `code-id`: Target project ID
    - `rating`: Score (0-5)
    - `feedback-text`: Detailed feedback (max 256 chars)

#### Read-Only Functions
- `get-code-project`: Retrieve project details
- `get-feedback-entry`: Access specific feedback
- `get-evaluator-deposit`: Check evaluator's staked amount

### Error Codes
- `u100`: Item not found
- `u101`: Access denied
- `u102`: Duplicate review
- `u103`: Invalid input
- `u104`: Overflow error
- `u105`: Insufficient balance

## Requirements
- Stacks blockchain compatibility
- Clarity smart contract support
- Minimum 100 STX collateral for evaluators

## Security Features
- Overflow protection
- Input validation
- Safe token transfer handling
- Collateral protection mechanisms
- Access control checks

## Usage Example

```clarity
;; Submit a project for review
(contract-call? .defi-review submit-code-project "MyDeFiProject" "v1.0.0")

;; Stake collateral as evaluator
(contract-call? .defi-review deposit-evaluator-collateral u1000)

;; Submit feedback
(contract-call? .defi-review submit-code-feedback u1 u4 "Excellent security measures, but needs better documentation")

;; Withdraw collateral
(contract-call? .defi-review withdraw-evaluator-collateral u500)
```

## Contributing
1. Fork the repository
2. Create your feature branch
3. Submit a pull request with comprehensive testing
4. Ensure all security measures are maintained


