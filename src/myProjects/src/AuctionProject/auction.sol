// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/console.sol";
import "forge-std/Test.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

contract AuctionContract {
    struct Auction {
        address seller;
        uint tokenId;
        uint endAt;
        bool started;
        address highestBidder;
        uint highestBid;
    }

    /*╔═════════════════════════════╗
      ║           EVENTS            ║
      ╚═════════════════════════════╝*/
    event withdrawBidEvent(address, uint);
    event addBidEvent(address, uint);
    event startAuctionEvent(address, uint);
    event endAuctionEvent(uint, address, uint);

    mapping(uint => Auction) public auctions;

    uint public auctionCounter = 0;

    IERC721 public nft;

    modifier OnlySeller(uint auctionId) {
        require(auctions[auctionId].seller == msg.sender);
        _;
    }

    function setEndAt(
        uint auctionId,
        uint newDate
    ) public OnlySeller(auctionId) {
        require(
            auctions[auctionId].endAt < newDate,
            "you can't short the auction time"
        );
        auctions[auctionId].endAt = newDate;
    }

    constructor(address _nftContract) {
        nft = IERC721(_nftContract);
    }

    function startAuction(
        uint endAt,
        uint tokenId
    ) public payable returns (uint) {
        auctions[auctionCounter].seller = msg.sender;
        auctions[auctionCounter].tokenId = tokenId;
        auctions[auctionCounter].endAt = endAt;
        auctions[auctionCounter].started = true;

        require(nft.ownerOf(tokenId) == msg.sender, "Not token owner");
        nft.transferFrom(msg.sender, address(this), tokenId);
        placeBid(auctionCounter);

        emit startAuctionEvent(msg.sender, auctionCounter);
        return auctionCounter++;
    }

    function placeBid(uint auctionId) public payable {
        require(auctions[auctionId].started, "this auction is not active");
        require(
            auctions[auctionId].endAt > block.timestamp,
            "this auction is no longer active, time is over"
        );
        require(
            msg.value > 0 && msg.value > (auctions[auctionId]).highestBid,
            "your bid is too less"
        );

        //transfer the previous bidder his funds
        payable(auctions[auctionId].highestBidder).transfer(
            auctions[auctionId].highestBid
        );

        //add the new higher bidder details
        auctions[auctionId].highestBid = msg.value;
        auctions[auctionId].highestBidder = msg.sender;

        emit addBidEvent(msg.sender, msg.value);
    }

    function auctionEnds(uint auctionId) public {
        require(
            block.timestamp > auctions[auctionId].endAt,
            "The end date of the auction has not yet ended"
        );
        require(auctions[auctionId].started, "The auction is already closed");
        //transfer the nft's to the highest bidder
        nft.approve(address(this), auctions[auctionId].tokenId);
        nft.transferFrom(
            address(this),
            auctions[auctionId].highestBidder,
            auctions[auctionId].tokenId
        );

        //transfer the payment of the highest bidder to the seller
        payable(auctions[auctionId].seller).transfer(
            auctions[auctionId].highestBid
        );
        auctions[auctionId].started = false;
        
        emit endAuctionEvent(
            auctionId,
            auctions[auctionId].highestBidder,
            auctions[auctionId].highestBid
        );
    }

    function getAuction(uint auctionId) public view returns (Auction memory) {
        return auctions[auctionId];
    }
}
