// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {DEX} from "../src/DEXProject/DEX.sol";
import {MyERC20} from "../src/DEXProject/erc20.sol";
contract DEXTest{
   uint constant WAD=10**18;

   DEX public myDEX;

   MyERC20 A;
   MyERC20 B;
   uint256 initialBalanceA = 50000;
   uint256 initialBalanceB = 50000;
   function setUp() public {
       A = new MyERC20(1000000);
       B = new MyERC20(1000000);       
       myDEX = new DEX(address(A), address(B));
       A.approve(address(myDEX),initialBalanceA);
       B.approve(address(myDEX),initialBalanceB);
       myDEX.initial(initialBalanceA,initialBalanceB);
    }

   
  
   function testTrade() public {
    console.log(myDEX.calculateBForATrade(7000));
    (uint256 a, uint256 b)=myDEX.getBalances();
    console.log("a ",a,"b ",b);
    A.approve(address(myDEX),7000);
    myDEX.tradeAtoB(7000);
    (a ,b)= myDEX.getBalances();
    console.log("a ",a,"b ",b);
    A.approve(address(myDEX),10000);
    console.log(myDEX.calculateBForATrade(10000));
    myDEX.tradeAtoB(10000);
    (a ,b)= myDEX.getBalances();
    console.log("a ",a,"b ",b);

    B.approve(address(myDEX),2000);
    console.log(myDEX.calculateAForBTrade(2000));
    myDEX.tradeBtoA(2000);
    (a ,b)= myDEX.getBalances();
    console.log("a ",a,"b ",b); 
///addLiquidity
    uint256 x=5000;
    console.log("-----");
    console.log("a ",a,"b ",b);  
    uint256 amountB=myDEX.priceA(x);
    A.approve(address(myDEX),x);
    B.approve(address(myDEX),amountB);
    console.log("a", x, "B",amountB);

    myDEX.addLiquidity(x,amountB);
    
    (uint256 aa ,uint256 bb)= myDEX.getBalances();
    console.log("a ",aa,"b ",bb);  
    console.log("b ",amountB,"    " ,b*WAD/a*x/WAD);   
    
    console.log(myDEX.investors(address(this)));

    B.approve(address(myDEX),2000);
    myDEX.tradeBtoA(2000);
    (a ,b)= myDEX.getBalances();
    console.log("a ",a,"b ",b );  

//removeLiquidity
    (uint256 maxA, uint256 maxB)=myDEX.getMaxLiquidityToRemove();
    console.log("max a  ", maxA, "max b  " ,maxB);
    (uint256 reala, uint256 realb, uint256 balance)=myDEX.removeLiquidity(maxA,maxB);
   
    //console.log("realA  ", reala, "realb  ",realb,"user balance   ",balance); 
    (a ,b)= myDEX.getBalances();
    console.log("a balance",a,"b balance",b );  

    



    }

//    function testAddLiquidity()public{
//     uint256 x=5000;
//     console.log("-----");
//     (uint256 a, uint256 b)=myDEX.getBalances();
//     console.log("a ",a,"b ",b);  
//     uint256 amountB=myDEX.priceA(x);
//     A.approve(address(myDEX),x);
//     B.approve(address(myDEX),amountB);
//     console.log("a", x, "B",amountB);

//     myDEX.addLiquidity(x,amountB);
    
//     (uint256 aa ,uint256 bb)= myDEX.getBalances();
//     console.log("a ",a,"b ",b);  
//     console.log("b ",amountB,"    " ,b/a*WAD*x/WAD);

//     //assertEq(amountB,a/b*WAD/x*WAD,"false");

//    }

   function removeLiquidity()public{
    

   }
   
}