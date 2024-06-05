// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import {MyERC20} from "./erc20.sol";
import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";

contract DEX {
    IERC20 public A;
    IERC20 public B;

    uint256 public _k;

    mapping(address => uint256) public investors;

    address public owner;

    uint256 WAD = 10 ** 18;

    constructor(address a, address b) {
        A = IERC20(a);
        B = IERC20(b);
        owner=msg.sender;
        console.log(A.balanceOf(msg.sender));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function initial(uint256 Abalance, uint256 Bbalance) public onlyOwner {
        require(Abalance > 0 && Bbalance > 0, "invalid initial balance");
        A.transferFrom(msg.sender, address(this), Abalance);
        B.transferFrom(msg.sender, address(this), Bbalance);
        _k = Abalance * Bbalance;
    }

    function getBalances() public view returns (uint256, uint256) {
        return (A.balanceOf(address(this)), B.balanceOf(address(this)));
    }

    function calculateBForATrade(uint256 amount) public view returns (uint256) {
        uint256 newA = A.balanceOf(address(this)) + amount;
        uint256 newB = (_k * WAD) / newA;
        uint256 oldB = B.balanceOf(address(this));
        return oldB - newB / WAD;
    }

    function calculateAForBTrade(uint256 amount) public view returns (uint256) {
        uint256 newB = B.balanceOf(address(this)) + amount;
        uint256 newA = (_k * WAD) / newB;
        uint256 oldA = A.balanceOf(address(this));
        return oldA - newA / WAD;
    }

    function tradeAtoB(uint256 amount) public payable returns (uint256) {
        uint256 returnAmount = calculateBForATrade(amount);
        A.transferFrom(msg.sender, address(this), amount);
        B.approve(address(this),returnAmount);
        B.transferFrom(address(this),msg.sender, returnAmount);
        return returnAmount;
    }

    function tradeBtoA(uint256 amount) public payable returns (uint256) {
        uint256 returnAmount = calculateAForBTrade(amount);
        B.transferFrom(msg.sender, address(this), amount);
        A.approve(address(this),returnAmount);
        A.transferFrom(address(this),msg.sender, returnAmount);
        return returnAmount;
    }

    //according to the current state- just for add liquidity and not for the trade
    function priceA(uint256 amount) public view returns (uint256) {
        uint256 amountA = A.balanceOf(address(this));
        uint256 amountB = B.balanceOf(address(this));
        return (amount * WAD) / ((amountA * WAD) / amountB);
    }

    function priceB(uint256 amount) public view returns (uint256) {
        uint256 amountA = A.balanceOf(address(this));
        uint256 amountB = B.balanceOf(address(this));
        uint256 percent = (amountB * WAD) / amountA;
        return (amount * WAD) / percent;
    }

    //the user can use getMaxLiquidity() and than use price() to get correct amounts that are in the same ratio
    function addLiquidity(uint256 amountA, uint256 amountB) public payable {
        require(
            amountA / amountB ==
                A.balanceOf(address(this)) / B.balanceOf(address(this)),
            "Amounts must be deposited in the correct ratio"
        );
        investors[msg.sender] += amountA + amountB;
        console.log(investors[msg.sender]);
        A.transferFrom(msg.sender, address(this), amountA);
        B.transferFrom(msg.sender, address(this), amountB);
        _k = A.balanceOf(address(this)) * B.balanceOf(address(this));
    }

    function getMaxLiquidityToRemove() public view returns (uint256, uint256) {
        uint256 Abalance = A.balanceOf(address(this));
        uint256 Bbalance = B.balanceOf(address(this));
        uint256 total = Bbalance + Abalance;
        uint256 ratio = (total *WAD/ investors[msg.sender]) ;

        uint256 maxB = (Bbalance * WAD) / ratio;
        uint256 maxA = (Abalance * WAD) / ratio;
        return (maxA, maxB);
    }

    function removeLiquidity(
        uint256 amountA,
        uint256 amountB
    ) public payable returns (uint256, uint256,uint256) {
        require(investors[msg.sender] > 0, "you can't remove liquidity");

        (uint256 maxA, uint256 maxB) = getMaxLiquidityToRemove();

        require(
            amountA / amountB ==
                A.balanceOf(address(this)) / B.balanceOf(address(this)),
            "Amounts must be removed in the correct ratio"
        );

        uint256 realAmountA = maxA > amountA ? amountA : maxA;
        uint256 realAmountB = maxB > amountB ? amountB : maxB;
        A.approve(address(this),realAmountA);
        B.approve(address(this),realAmountB);
        A.transferFrom(address(this), msg.sender, realAmountA);
        B.transferFrom(address(this), msg.sender, realAmountB);

        investors[msg.sender] -= (realAmountA + realAmountB);
        _k = A.balanceOf(address(this)) * B.balanceOf(address(this));

        return (realAmountA, realAmountB,investors[msg.sender]);
    }
}
