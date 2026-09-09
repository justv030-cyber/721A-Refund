# Cortex ERC721R NFT  -- harshil thummar

Cortex is an **ERC721R-based NFT smart contract** that implements NFT minting with a built-in **refund mechanism**. NFT holders can return their NFT within a predefined refund period and receive the mint price back.

## 🚀 Features

* ERC721A-based NFT implementation
* ERC721R refund mechanism
* Fixed mint price
* Maximum NFTs per wallet
* Maximum collection supply
* Refund period
* Token-specific refund deadlines
* Prevents double refunds
* Owner-only minting
* Owner withdrawal functionality
* IPFS-based metadata
* Solidity `^0.8.27`

## 📋 Contract Configuration

| Parameter         |   Value |
| ----------------- | ------: |
| NFT Name          |  Cortex |
| Symbol            |     CTX |
| Mint Price        |   1 ETH |
| Max Mint Per User |       4 |
| Maximum Supply    |  10,000 |
| Refund Period     | 10 Days |
| Solidity Version  | ^0.8.27 |

## 🏗️ Architecture

The contract inherits from:

```solidity
ERC721A
IERC721R
Ownable
```

### ERC721A

Provides gas-efficient ERC721 NFT functionality and batch minting.

### IERC721R

Defines the refund-related functionality used by the ERC721R implementation.

### Ownable

Provides owner access control for administrative functions such as minting and withdrawing funds.

---

# 🪙 Minting

The contract provides an owner-only `safeMint()` function.

```solidity
function safeMint(uint256 quantity) public payable onlyOwner
```

### Mint Requirements

The following conditions are checked:

1. Quantity must be greater than zero.
2. Caller must send at least the required mint price.
3. Wallet mint limit cannot exceed `mintPerUser`.
4. Collection supply cannot exceed `totalSupplyLimit`.

Example:

```text
Mint Price     = 1 ETH
Max Per Wallet = 4 NFTs

Quantity = 2

Required Payment = 2 ETH
```

---

# 🔄 Refund Mechanism

The main feature of this contract is the NFT refund functionality.

NFT holders can call:

```solidity
refund(uint256 tokenId)
```

before the refund deadline.

### Refund Requirements

The refund is allowed only when:

* The caller owns the NFT.
* The refund deadline has not passed.
* The NFT has not already been refunded.

```solidity
require(
    msg.sender == ownerOf(tokenId),
    "You Are Not Owner Of This NFT"
);
```

The refund deadline is checked using:

```solidity
getrefundDeadLine(tokenId)
```

---

# ⏱️ Refund Period

The refund period is configured as:

```solidity
uint256 public constant refundPeriod = 10 days;
```

When NFTs are minted, a refund timestamp is assigned to each token.

```solidity
refundTimestamps[tokenId] = refundTimeStamp;
```

The deadline can be queried using:

```solidity
getrefundDeadLine(tokenId)
```

---

# 💰 Refund Amount

The refund amount is currently equal to the fixed mint price:

```solidity
function getRefundAmt(uint256 tokenId)
    public
    view
    returns (uint256)
{
    if (hasRefunded[tokenId]) {
        return 0;
    }

    return mintPrice;
}
```

Since:

```text
mintPrice = 1 ETH
```

the refund amount is:

```text
1 ETH
```

for each eligible NFT.

---

# 🔐 Preventing Double Refunds

The contract uses:

```solidity
mapping(uint256 => bool) public hasRefunded;
```

to track whether a token has already been refunded.

After a successful refund:

```solidity
hasRefunded[tokenId] = true;
```

This prevents the same token from being refunded multiple times.

---

# 💸 ETH Transfer

The refund amount is transferred to the NFT owner using Solidity's low-level `call`:

```solidity
(bool success, ) = payable(msg.sender).call{
    value: refundAmt
}("");
```

The transaction reverts if the transfer fails.

---

# 📦 Token Metadata

The contract uses an IPFS base URI:

```solidity
function _baseURI()
    internal
    pure
    override
    returns (string memory)
{
    return "ipfs://QmbseRTJWSsLfhsiWwuB2R7EtN93TxfoaMz1S5FXtsFEUB/";
}
```

Token metadata is therefore resolved using:

```text
ipfs://<CID>/<tokenId>
```

For example:

```text
ipfs://QmbseRTJWSsLfhsiWwuB2R7EtN93TxfoaMz1S5FXtsFEUB/1
```

---

# 👑 Owner Functions

## `safeMint()`

Mints NFTs.

```solidity
safeMint(uint256 quantity)
```

Only the contract owner can call this function.

## `withdraw()`

Allows the owner to withdraw the ETH held by the contract.

```solidity
withdraw()
```

---

# 📖 Read Functions

### `getrefundDeadLine()`

Returns the refund deadline for a token.

```solidity
getrefundDeadLine(uint256 tokenId)
```

### `getRefundAmt()`

Returns the eligible refund amount.

```solidity
getRefundAmt(uint256 tokenId)
```

### `refundTimestamps()`

Returns the stored refund timestamp for a token.

### `hasRefunded()`

Returns whether a token has already been refunded.

---

# 🔄 User Flow

```text
        ┌─────────────────┐
        │   Deploy NFT    │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │     Mint NFT    │
        │     1 ETH       │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │ Refund Window   │
        │    10 Days      │
        └────────┬────────┘
                 │
          ┌──────┴──────┐
          │             │
          ▼             ▼
      Refund NFT     Keep NFT
          │
          ▼
    ┌───────────────┐
    │ NFT Returned  │
    │ ETH Refunded  │
    └───────────────┘
```

---

# 🛡️ Security Considerations

This contract should be thoroughly tested and audited before handling real funds.

Important areas to review include:

* Reentrancy protection
* Refund accounting
* NFT ownership changes
* Refund deadline calculation
* Contract ETH balance
* Owner withdrawal
* Refund state management
* Token transfer behavior
* Batch minting
* Edge cases around refund expiration

> **Important:** This repository is for development/educational purposes unless explicitly audited and tested for production use.

---

# 🧪 Testing

Recommended tests should cover:

### Mint Tests

* Mint 1 NFT
* Mint multiple NFTs
* Mint zero NFTs
* Exceed wallet limit
* Exceed collection supply
* Insufficient payment

### Refund Tests

* Refund an owned NFT
* Refund after deadline
* Refund someone else's NFT
* Refund the same NFT twice
* Refund after NFT transfer
* Refund when contract has insufficient ETH

### Withdrawal Tests

* Owner withdrawal
* Non-owner withdrawal
* Withdrawal after refunds

---

# 🛠️ Tech Stack

* Solidity `^0.8.27`
* ERC721A
* ERC721R
* OpenZeppelin
* Ethereum / EVM-compatible networks
* IPFS
* Hardhat / Remix

---

# ⚠️ Important Note

The current implementation uses a fixed `refundTimeStamp` that is assigned during minting and then stored for each minted token.

Before deploying to mainnet, the refund flow should be tested carefully, particularly the interaction between `_transfer()`, ownership, refund accounting, and the contract's ETH balance.

---

# 📄 License

This project is licensed under the **MIT License**.

---

## ⭐ Summary

Cortex ERC721R combines the gas efficiency of **ERC721A** with a **time-limited NFT refund mechanism**.

The core concept is:

```text
Mint NFT
   ↓
10-Day Refund Window
   ↓
Return NFT
   ↓
Receive Mint Price
```

This provides NFT buyers with a predefined period during which they can return an eligible NFT and recover the configured mint price.
