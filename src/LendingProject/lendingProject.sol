// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "forge-std/console.sol";
import "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {BondToken} from "./bondToken.sol";
import "../../lib/foundry-chainlink-toolkit/src/interfaces/feeds/AggregatorV2V3Interface.sol";

contract LendingProject {
    struct Lender {
        uint amount;
    }

    struct Borrower {
        uint collateral;
        uint borrow;
    }
    
    uint constant public WAD=10**18;
    uint public maxLTV = 80;
    uint public _borrowFee = 3;
    uint public _liquidationThreshold=90;
    uint public _totalDeposits;
    address public owner;
    mapping(address => Lender) public lenders;
    address[] public lendersAddresses;
    mapping(address => Borrower) public borrowers;
    address[] public borrowersAddresses;

    //tokens
    IERC20 public DAI;
    //IERC20 public collateraltoken; ethereum moved by msg.value
    BondToken public bondToken;
    AggregatorV3Interface internal priceFeed;
    //events

    event Deposit(address, uint);
    event Withdraw(address, uint);
    event LogPrice(uint);
    event Borrow(address, uint);
    event RepayBorrow(address, uint, uint);
    event RemoveCollateral(address, uint);

    constructor(address dai) {
        owner = msg.sender;
        DAI = IERC20(dai);//0x6B175474E89094C44Da98b954EedeAC495271d0F
        bondToken = new BondToken();

        priceFeed = AggregatorV3Interface(
            0x779877A7B0D9E8603169DdbD7836e478b4624789
        );
    }

    function getEthToDaiPrice() public view returns (uint) {
        //(, int price, , ,) = priceFeed.latestRoundData(); blocked by netfree
        uint price = 3110; //this is the current price of 1 eth by usd - should by worth to dai as stablecoin (called to api https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd)
        return price; // Price is returned with 8 decimals, adjust accordingly
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function deposit(uint amount) public payable {
        if (lenders[msg.sender].amount == 0) lendersAddresses.push(msg.sender);
        lenders[msg.sender].amount += amount;
        //deposit amount from token
        DAI.transferFrom(msg.sender, address(this), amount);
        bondToken.mint(msg.sender, amount);
        _totalDeposits+=amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint amount) public payable {
        require(
            lenders[msg.sender].amount > amount,
            "You do not have enough balance to withdraw"
        );
        DAI.approve(address(this),amount);
        DAI.transferFrom(address(this), msg.sender, amount);
        bondToken.burn(msg.sender, amount);
        lenders[msg.sender].amount -= amount;
        _totalDeposits-=amount;
        emit Withdraw(msg.sender, amount);
    }

    function borrow(uint borrowAmount) public payable {
        if (msg.value > 0) addCollateral();

        uint ETHByUSDC = borrowers[msg.sender].collateral * getEthToDaiPrice(); //getLatestPrice();

        uint borrowLimit = percentage(ETHByUSDC, maxLTV) -
            borrowers[msg.sender].borrow;
        require(
            borrowAmount <= borrowLimit,
            "You didn't put enough collateral"
        );
        borrowers[msg.sender].borrow+=borrowAmount;
        DAI.approve(address(this),borrowAmount);
        DAI.transferFrom(address(this), msg.sender, borrowAmount);
        emit Borrow(msg.sender, borrowAmount);
    }

    function repayBorrow(uint amount) public payable {
        uint fee = percentage(amount, _borrowFee);
        borrowers[msg.sender].borrow -= amount;
        DAI.transferFrom(msg.sender, address(this), amount + fee);
        distributionOfRewards(fee);
        emit RepayBorrow(msg.sender, amount, fee);
    }

    function removeCollateral(uint amount) public {
        uint ETHByUSDC = borrowers[msg.sender].collateral * getEthToDaiPrice(); //getLatestPrice();

        require(
            ((borrowers[msg.sender].borrow>0)&& (borrowers[msg.sender].borrow * WAD) /
                (((ETHByUSDC - amount) * WAD) / 100) >
                maxLTV),
            "you can't remove this amount, your borrow is too high"
        );
        payable(msg.sender).transfer(amount);
        borrowers[msg.sender].collateral-=amount;
        emit RemoveCollateral(msg.sender, amount);
    }

    function triggerLiquidation() public onlyOwner {
        
        for (uint i=0;i<borrowersAddresses.length;i++){
                 uint ETHByUSDC = borrowers[borrowersAddresses[i]].collateral * getEthToDaiPrice(); //getLatestPrice();
                 if(((borrowers[msg.sender].borrow>0)&& (borrowers[msg.sender].borrow * WAD) /(((ETHByUSDC) * WAD) / 100) > _liquidationThreshold)){
                    harvestRewards( borrowers[borrowersAddresses[i]].collateral- percentage(borrowers[borrowersAddresses[i]].collateral,_liquidationThreshold));
                    //uniswap.swap(address(DAI),borrowers[borrowersAddresses[i]].collateral); in the liquidation we swap in uniswap to dai
                    borrowers[borrowersAddresses[i]].collateral=0;
                    
                 }                     
        }
    }

    function harvestRewards(uint amount) internal onlyOwner {
        payable(owner).transfer(amount);
    }

    function convertTreasury() public onlyOwner {}

    function distributionOfRewards(uint fee) internal {
        for (uint i = 0; i < lendersAddresses.length; i++) {
            uint reward = (
                fee*
                (_totalDeposits*WAD /
                    lenders[lendersAddresses[i]].amount)
            )/WAD;
            console.log(_totalDeposits);
            console.log(reward, lenders[lendersAddresses[i]].amount);
            DAI.approve(address(this),reward);
            DAI.transferFrom(address(this), lendersAddresses[i], reward);
        }
    }

    function percentage(uint x, uint y) internal pure returns (uint) {
        return (x * y) / 100;
    }

    function addCollateral() internal returns (uint) {
        borrowers[msg.sender].collateral += msg.value;
    }
}
