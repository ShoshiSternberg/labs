// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {LendingProject} from "../src/LendingProject/lendingProject.sol";
//import  "forge-std/mocks/MockERC721.sol";
 import {MyERC20} from "../src/DEXProject/erc20.sol";

contract LendingProjectTest is Test {
    MyERC20 public dai;
    LendingProject public l;

    function setUp() public {
        dai=new MyERC20(1000000);
        l=new LendingProject(address(dai));
    }

    function testDeposit()public{
        vm.startPrank(address(1));
        dai.mint(address(1),1000);
        dai.approve(address(l),1000);
        l.deposit(1000);

        vm.stopPrank();

        vm.startPrank(address(2));
        vm.deal(address(2),800);
        l.borrow{value:80}(100);
        

        console.log("dai balance of the contract",dai.balanceOf(address(l)));
        console.log("dai balance of the borrower",dai.balanceOf(address(2)));
        console.log("dai balance of the lender",dai.balanceOf(address(1)));

        console.log("eth balance of the contract",(address(l).balance));
        console.log("eth balance of the borrower",(address(2)).balance);
        console.log("eth balance of the lender",(address(1)).balance);
        dai.approve(address(l),100);
        l.repayBorrow(60);

        console.log("dai balance of the contract",dai.balanceOf(address(l)));
        console.log("dai balance of the borrower",dai.balanceOf(address(2)));
        console.log("dai balance of the lender",dai.balanceOf(address(1)));

        console.log("eth balance of the contract",(address(l).balance));
        console.log("eth balance of the borrower",(address(2)).balance);
        console.log("eth balance of the lender",(address(1)).balance);

        vm.stopPrank();

        
    }


}
