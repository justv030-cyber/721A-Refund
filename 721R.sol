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

    uint256 public constant refundPeriod = 10 days;

    mapping(uint256 => uint256) public refundTimestamps;

    mapping(uint256 => bool) public hasRefunded;

    address public refundAdddress;
    uint256 public refundTimeStamp;
    uint256 public refundAmt;

    constructor(
        address initialOwner
    ) ERC721A("Cortex ", "CTX") Ownable(initialOwner) {
        refundAdddress = address(this);
        refundTimeStamp = block.timestamp + refundPeriod;
    }

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

        refundTimeStamp = block.timestamp + refundPeriod;

        for (uint256 i = _currentIndex - quantity; i < _currentIndex; i++) {
            refundTimestamps[i] = refundTimeStamp;
        }
    }

    function refund(uint256 tokenId) external {
        require(
            msg.sender == ownerOf(tokenId),
            "You Are Not Owner Of This NFT"
        );
        require(
            block.timestamp <= getrefundDeadLine(tokenId),
            "Deadline Reached"
        );
        require(!hasRefunded[tokenId], "Already Refunded");
        refundAmt = getRefundAmt(tokenId);

        //ownership
        _transfer(address(this), refundAdddress, tokenId);

        // make a yes refuned NFT

        hasRefunded[tokenId] = true;

        // pay

        (bool sucess, ) = payable(msg.sender).call{value: refundAmt}("");

        require(sucess, "Transfer Failed");
    }

    function getrefundDeadLine(uint256 tokenId) public view returns (uint256) {
        if (hasRefunded[tokenId]) {
            return 0;
        }
        return refundTimestamps[tokenId];
    }

    function getRefundAmt(uint256 tokenId) public view returns (uint256) {
        if (hasRefunded[tokenId]) {
            return 0;
        }
        return mintPrice;
    }

    function withdraw() external onlyOwner {
        require(
            block.timestamp > refundTimeStamp,
            "Please Try Again After Some Time"
        );
        uint256 currentBalance = address(this).balance;
        (bool sucess, ) = payable(msg.sender).call{value: currentBalance}("");
        require(sucess, "Transfer Failed");
    }
}
