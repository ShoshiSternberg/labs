// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {AuctionContract} from "../src/AuctionProject/auction.sol";
//import  "forge-std/mocks/MockERC721.sol";
import {MyERC721} from "../src/AuctionProject/myERC721.sol";

contract AuctionTest is Test {
    AuctionContract public auctions;
    MyERC721 public token;

    function setUp() public {
        token = new MyERC721("myNFT", "MYNFT");
        auctions = new AuctionContract(address(token));
    }

    function testStartAuction() public returns (uint) {
        //to set the token in address(this) balance
        uint tokenid = 1;

        token.mint(address(this), tokenid);
        token.approve(address(auctions), tokenid);
        uint auctionId = auctions.startAuction{value: 10}(
            //address(token),
            block.timestamp + 24,
            tokenid
        );

        console.log("auction id ", auctionId);
        console.log("seller ", auctions.getAuction(auctionId).seller);
        console.log(
            "highest bidder ",
            auctions.getAuction(auctionId).highestBidder
        );
        console.log("highest bid ", auctions.getAuction(auctionId).highestBid);
        assertEq(token.ownerOf(1),address(auctions),"the ownership of the token transfered to the contract");
        return auctionId;
    }

    receive() external payable {}

    function testplaceBid() public {
        //start auction
        uint auctionId = testStartAuction();
        

        //place bid 1
        vm.startPrank(address(4));
        vm.deal(address(4), 100 ether);
        auctions.placeBid{value: 25}(auctionId);
        vm.stopPrank();
        
        //place bid 2
        vm.startPrank(address(5));
        vm.deal(address(5), 100 ether);
        uint highestBid = 30;
        auctions.placeBid{value: highestBid}(auctionId);
        
        //end auction
        vm.warp(300);
        uint sellerBalance = auctions.getAuction(auctionId).seller.balance;
        auctions.auctionEnds(auctionId);
        assertEq(
            auctions.getAuction(auctionId).seller.balance -
                sellerBalance , highestBid,
            "the seller should get the highest bid to his wallet"
        );

        
        console.log(token.ownerOf(1));
        vm.stopPrank();
    }
}
