// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.7.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/ERC721A.sol";
import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/IERC721R.sol";

abstract contract Cortex is ERC721A, IERC721R, Ownable {
    uint256 public constant mintPrice = 1 ether;
    uint256 public constant mintPerUser = 4;
    uint256 public constant totalSupplyLimit = 10000;

    constructor(
        address initialOwner
    ) ERC721A("Cortex ", "CTX") Ownable(initialOwner) {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmbseRTJWSsLfhsiWwuB2R7EtN93TxfoaMz1S5FXtsFEUB/";
    }

    function safeMint(uint256 quantity) public payable onlyOwner {
        require(quantity > 0, "Quantity must be greater than 0");
        require(msg.value >= mintPrice * quantity, "Insufficient funds");
        require(
            _numberMinted(msg.sender) + quantity <= mintPerUser,
            "Mint Limit Reacheds"
        );
        require(
            _totalMinted() + quantity <= totalSupplyLimit,
            "Supply Limit Reached"
        );

        _safeMint(msg.sender, quantity);
    }
}
