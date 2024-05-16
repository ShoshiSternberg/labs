// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {LendingProject} from "../src/LendingProject/lendingProject.sol";
//import  "forge-std/mocks/MockERC721.sol";
// import {MyERC721} from "../src/AuctionProject/myERC721.sol";

contract LendingProjectTest is Test {
    LendingProject public l;

    function setUp() public {
        l=new LendingProject();
    }

    function testDeposit()public{
        l.getEthToDaiPrice();
    }


}
