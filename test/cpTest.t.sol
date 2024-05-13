// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {CP} from "../src/DEXProject/cp.sol";
import {MyERC20} from "../src/DEXProject/erc20.sol";
import "forge-std/interfaces/IERC20.sol";

contract CpTest is Test{
    MyERC20 public token0;
    MyERC20 public token1;

    CP public myCp;

    function setUp() public{
        token0=new MyERC20(50000);
        token1=new MyERC20(50000);
        myCp=new CP(address(token0),address(token1));        
    }

    function testSwap() public{
        vm.startPrank(address(4));
        token0.mint(address(4),500);
        token0.approve(address(myCp),5);
        myCp.swap(address(token0), 5);
        console.log("token0 ",token0.balanceOf(address(this)));
        console.log("token1 ",token1.balanceOf(address(this)));
        vm.stopPrank();
    }


    function testAddLiquidity()public{
        //Shimon deposit 5,10
        vm.startPrank(address(1));
        token0.mint(address(1), 50000);
        token1.mint(address(1), 50000);
        token0.approve(address(myCp),5);
        token1.approve(address(myCp),10);
        uint shares=myCp.addLiquidity(5,10);
        console.log(shares);
        vm.stopPrank();

        //reuven deposit 15, 30

        vm.startPrank(address(2));
        token0.mint(address(2), 50000);
        token1.mint(address(2), 50000);
        token0.approve(address(myCp),15);
        token1.approve(address(myCp),30);
        shares=myCp.addLiquidity(15,30);
        console.log(shares);

        //levi
        vm.startPrank(address(3));
        token0.mint(address(3), 50000);
        token1.mint(address(3), 50000);
        token0.approve(address(myCp),1);
        token1.approve(address(myCp),2);
        shares=myCp.addLiquidity(1,2);
        console.log(shares);
    }
}