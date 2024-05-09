// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {AuctionContract} from "../src/AuctionProject/auction.sol";
import  "forge-std/mocks/MockERC721.sol";

contract AuctionTest is Test{

    AuctionContract public auctions;

    function setUp()public{

        auctions=new AuctionContract();
    }

    function testStartAuction()public returns(uint){
        MockERC721 token=new MockERC721();
        //to set the token in address(this) balance
        uint auctionId=auctions.startAuction(address(token),block.timestamp+24,1);
        return auctionId;
    }

    function testAddBid()public{
        uint auctionId=testStartAuction();
        vm.startPrank(address(1));
        vm.deal(address(1),100 ether);
        //to put value in msg.value
        auctions.addBid(auctionId);
    }
}