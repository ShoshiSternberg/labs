// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

contract AuctionContract{

    struct Auction {
        
        address seller;
        IERC721 NFT;
        uint tokenId;
        uint endAt;
        bool started;        
        mapping(address=>uint) bids;
        address [] biddersAddresses;
        address highestBidder;
    } 

    event withdrawBidEvent(address, uint);
    event addBidEvent(address, uint);
    event startAuctionEvent(address, uint);
    event endAuctionEvent(uint,address, uint);


    mapping(uint=>Auction) public auctions;

    uint public auctionCounter=0;

    modifier OnlySeller(uint auctionId){
        require(auctions[auctionId].seller==msg.sender);
        _;
    }   

    function setEndAt(uint auctionId,uint newDate) public OnlySeller(auctionId){
        require(auctions[auctionId].endAt<newDate,"you can't short the auction time");
        auctions[auctionId].endAt=newDate;
    }

    function startAuction(address nft, uint endAt,uint tokenId) public returns(uint){
        
        auctions[auctionCounter].seller=msg.sender;
        auctions[auctionCounter].NFT=IERC721(nft);
        auctions[auctionCounter].tokenId=tokenId;
        auctions[auctionCounter].endAt=endAt;
        auctions[auctionCounter].started=true;

        auctions[auctionCounter].NFT.transferFrom(msg.sender,address(this),tokenId);
        addBid(auctionCounter);

        emit startAuctionEvent(msg.sender,auctionCounter);
        return auctionCounter++;
    }
    
    
    function addBid(uint auctionId) public payable {
        require(auctions[auctionId].started,"this auction is not active");
        require(auctions[auctionId].endAt>block.timestamp,"this auction is no longer active, time is over");
        require(msg.value>0&&msg.value>(auctions[auctionId]).bids[ (auctions[auctionId]).highestBidder],"your bid is too less");
        if(auctions[auctionId].bids[msg.sender]>0)
            withdrawBid(auctionId);
        auctions[auctionId].bids[msg.sender]=msg.value;
        (auctions[auctionId].biddersAddresses).push(msg.sender);
        auctions[auctionId].highestBidder=msg.sender;  

        emit addBidEvent(msg.sender,msg.value);      

    }

    function withdrawBid(uint auctionId) payable public {
        require(msg.sender!=auctions[auctionId].highestBidder,"the highest bidder can't withdraw his bid");
        uint withdrawAmount=auctions[auctionId].bids[msg.sender];
        payable(msg.sender).transfer(auctions[auctionId].bids[msg.sender]);
        auctions[auctionId].bids[msg.sender]=0;
        emit withdrawBidEvent(msg.sender,withdrawAmount);        
    }

    function auctionEnds(uint auctionId) public {
        require(block.timestamp>auctions[auctionId].endAt,"The end date of the auction has not yet ended");
        for(uint i=((auctions[auctionId].biddersAddresses).length)-1;i>0;i--){
            payable(auctions[auctionId].biddersAddresses[i]).transfer(auctions[auctionId].bids[auctions[auctionId].biddersAddresses[i]]);
            auctions[auctionId].bids[auctions[auctionId].biddersAddresses[i]]=0;
            auctions[auctionId].biddersAddresses.pop();

        }
        auctions[auctionId].NFT.approve(address(this),auctions[auctionId].tokenId);
        auctions[auctionId].NFT.transferFrom(address(this),auctions[auctionId].highestBidder,auctions[auctionId].tokenId);
        payable(auctions[auctionId].seller).transfer(auctions[auctionId].bids[auctions[auctionId].highestBidder]);

        emit endAuctionEvent(auctionId,auctions[auctionId].highestBidder,auctions[auctionId].bids[auctions[auctionId].highestBidder]);


    }



}