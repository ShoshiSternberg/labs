// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {AuctionContract} from "../src/AuctionProject/auction.sol";
//import  "forge-std/mocks/MockERC721.sol";
import {MyERC721} from "../src/AuctionProject/myERC721.sol";

contract AuctionFuzzTest is Test {
    AuctionContract public auctions;
    MyERC721 public token;

    function setUp() public {
        token = new MyERC721("myNFT", "MYNFT");
        auctions = new AuctionContract();
    }

    receive() external payable {}

    function testStartAuction(uint tokenid,uint endAt,uint bid) public returns (uint) {
        //to set the token in address(this) balance
        //uint tokenid = 1;
        
        token.mint(address(this), tokenid);
        token.approve(address(auctions), tokenid);
        uint auctionId = auctions.startAuction{value: bid}(
            //address(token),
            block.timestamp + endAt,
            address(token),
            tokenid
        );

        console.log("auction id ", auctionId);
        console.log("seller ", auctions.getAuction(auctionId).seller);
        console.log(
            "highest bidder ",
            auctions.getAuction(auctionId).highestBidder
        );
        console.log("highest bid ", auctions.getAuction(auctionId).highestBid);
        assertEq(token.ownerOf(tokenid),address(auctions),"the ownership of the token transfered to the contract");
        return auctionId;
    }


    function testplaceBid(uint tokenid,uint endAt  ,uint bid,address bidder1,address bidder2,uint bid1, uint bid2) public {
        vm.assume(tokenid==1);
        vm.assume(bid<bid1);
        vm.assume(bid1<bid2);

        //start auction
        uint auctionId = testStartAuction(tokenid,endAt, bid);        

        //place bid 1
        vm.startPrank(bidder1);
        vm.deal(bidder2, bid1);
        auctions.placeBid{value: bid1}(auctionId);
        vm.stopPrank();
        
        //place bid 2
        vm.startPrank(bidder2);
        vm.deal(bidder2, bid2);
        uint highestBid = bid2;
        auctions.placeBid{value: highestBid}(auctionId);
        
        //end auction
        vm.warp(endAt+1);
        uint sellerBalance = auctions.getAuction(auctionId).seller.balance;

        auctions.auctionEnds(auctionId);
        assertEq(
            auctions.getAuction(auctionId).seller.balance -
                sellerBalance , highestBid,
            "the seller should get the highest bid to his wallet"
        );

        assertEq(bidder2,token.ownerOf(tokenid),"the ownership of the token transfered from the contract to the highest bidder");
        console.log(token.ownerOf(tokenid));
        vm.stopPrank();
    }
}
