// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/console.sol";
import "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {BondToken} from "./bondToken.sol";



contract LendingProject{

    struct Lender{
        uint amount;       
    }

    struct Borrower{
        uint collateral;
        uint borrow;        
    }
    
    uint public maxLTV;
    address public owner;
    mapping(address=>Lender) public lenders;
    address [] public lendersAddresses;
    mapping (address=>Borrower) public borrowers;
    address [] public borrowersAddresses;


    //tokens
    IERC20 public DAI;
    //IERC20 public collateraltoken; ethereum moved by msg.value 
    BondToken public bondToken; 
    //events

    event Deposit(address,uint);
    event Withdraw(address,uint);


    constructor(){
        owner=msg.sender;        
        DAI=IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        bondToken=new BondToken();    

        priceFeed = AggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);
    }  
    

    function getEthToDaiPrice() public view returns (int) {
        (, int price, , ,) = priceFeed.latestRoundData();
        return price; // Price is returned with 8 decimals, adjust accordingly
    }

        
    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function deposit(uint amount) public payable {
        if(lenders[msg.sender]==0)
            lendersAddresses.push(msg.sender);
        lenders[msg.sender].amount+=amount;
        //deposit amount from token 
        DAI.transferFrom(msg.sender,address(this),amount);
        bondToken.mint(msg.sender,amount);
        
        emit Deposit(msg.sender,amount);
    }

    function withdraw(uint amount)public payable {
        require(lenders[msg.sender].amount>amount,"You do not have enough balance to withdraw");
        payable(msg.sender).transfer(amount);
        bondToken.burn(msg.sender,amount);
        lenders[msg.sender].amount-=amount;

        emit Withdraw(msg.sender,amount);

    }

    function borrow(uint borrowAmount) public payable {
        if(msg.value>0)
            addCollateral();

        uint DAIByUSDC=address(uniswap).getPrice(borrowAmount);
        uint borrowLimit= percentage(borrowers[msg.sender].collateral, maxLTV)-borrowers[msg.sender].borrow;
        require(borrowAmount<=borrowLimit,"You didn't put enough collateral");

        DAI.transferFrom(address(this),msg.sender,borrowAmount);
     //if msg.value >0, call addCollateral, else, he just get the amount he wants unless he hasn't enough collaterals
    }

    function repayBorrow()public payable{

    }

    function getMaxBorrowPerCollateral() public view returns(uint){

    }

    function removeCollateral() public {

    }

    function triggerLiquidation()public OnlyOwner{

    }

    function harvestRewards()public OnlyOwner{

    }

    function convertTreasury ()public OnlyOwner{

    }

    function percentage(uint x, uint y) pure internal returns(uint){
        return (x*y)/100;
    }

    function addCollateral() internal returns(uint){
        borrowers[msg.sender].collateral+=msg.value;
    }




}