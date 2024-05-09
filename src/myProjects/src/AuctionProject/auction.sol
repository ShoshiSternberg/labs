// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import {MyERC20} from "./erc20.sol";
import "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/ierc721.sol";

contract AuctionContract{

    struct Auction {
        
        address seller;
        IERC721 NFT;
        uint tokenId;
        uint endAt;
        bool started;        
        mapping(address->uint) bids;
        address [] biddersAddresses;
        address highestBidder;
    } 

    
    
    mapping(uint->Auction) public auctions;
    uint public auctionCounter=0;

    modifier OnlySeller(uint auctionId){
        require(auctions[auctionId].seller==msg.sender);
        _;
    }   

    function setEndAt(uint auctionId,uint newDate) public OnlySeller(auctionId){
        require(auctions[auctionId].endAt<newDate,"you can't short the auction time");
        auctions[auctionId].endAt=newDate;
    }

    function startAuction(address nft, uint endAt,uint tokenId,uint bid) public returns(uint){
        Auction auction=Auction({

            seller:msg.sender;
            NFT=IERC721(nft);
            endAt=endAt;
            started:true;
        });

        auctions[auctionCounter]=auction;
        auctions[auctionCounter].NFT.transferFrom(msg.sender,address(this),tokenId);
        bid(auctionCounter++,bid);

    }

    function bid(uint auctionId,uint bid) public returns(bool){
        require(auctions[auctionId].started,"this auction is no ");
        require(bid>(auctions[auctionId]).bids[ (auctions[auctionId]).highestBidder],"your bid is too less");
        auctions[auctionId].bids[msg.sender]=bid;
        (auctions[auctionId].biddersAddresses).push(msg.sender);
        

    }

}