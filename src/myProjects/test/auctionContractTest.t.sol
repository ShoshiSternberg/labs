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

    function testStartAuction()public {
        MockERC721 token=new MockERC721();
        auctions.startAuction(address(token),block.timestamp+24,1);
    }
}