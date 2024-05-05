// SPDX-License-Identifier: MIT


pragma solidity ^0.8.20;
import {MyERC20} from "./erc20.sol";

contract DEX{

    MyERC20 public A;
    MyERC20 public B;

    uint256 public _total;
    uint256 public _k;

    mapping (address => uint256) investors;

    uint256 WAD=10**18;

    constructor(uint256 a, uint256 b){
        
        initial(a,b);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }


    function initial(uint256 Abalance, uint256 Bbalance) internal onlyOwner{

        require(Abalance>0&&Bbalance>0,"invalid initial balance");

        A.mint(address(this),Abalance);
        B.mint(address(this),Bbalance);
        _total=Abalance+Bbalance;
        _k=Abalance*Bbalance;

    }

    function price(uint256 amount)public view returns(uint256){
        

    }

    function tradeAtoB(uint256 amount){

        uint256 newA= A.balanceOf(address(this))+amount;
        uint256 newB= _k/newA;
        uint256 oldB=A.balanceOf(address(this));
        A.transferFrom(msg.sender,address(this),amount);
        B.transfer(msg.sender,oldB-newB);
        return oldB-newB;  

    }

    function tradeBtoA(uint256 amount) public payable {
        uint256 newB= B.balanceOf(address(this))+amount;
        uint256 newA= _k*WAD/newB;
        uint256 oldA=A.balanceOf(address(this));
        B.transferFrom(msg.sender,address(this),amount);
        A.transfer(msg.sender,oldA-newA/WAD);
        return oldA-newA/WAD;    
    }


    function addLiquidity(uint256 amountA, uint256 amountB) public returns(bool){
         require(amountA/amountB== A.balanceOf(address(this))/B.balanceOf(address(this)),"Amounts must be deposited in the correct ratio");
         investors[msg.sender]+=amountA+amountB;
         _total+=amountA+amountB;

         A.transferFrom(msg.sender,address(this),amountA);
         B.transferFrom(msg.sender,address(this),amountB);
         
    }


    function removeLiquidity(uint256 amountA, uint256 amountB) public returns(uint256, uint256){
        require(investors[msg.sender]>0,"you can't remove liquidity");
        uint256 ratio=_total/investors[msg.sender]*WAD;

        uint256 maxB=B.balanceOf(address(this))*WAD/ratio;
        uint256 maxA=A.balanceOf(address(this))*WAD/ratio;

        A.transferFrom(address(this),msg.sender,maxA>amountA?amountA:maxA);
        B.transferFrom(address(this),msg.sender,maxB>amountB?amountB:maxB);

        return(maxA>amountA?amountA:maxA,maxB>amountB?amountB:maxB);      


    }


    
}