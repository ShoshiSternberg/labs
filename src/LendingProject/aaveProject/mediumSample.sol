//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

import "./interfaces/ISwapRouter.sol";
import "./InnerMath.sol";
import "./moreMath.sol";
import "../bondToken.sol";

interface ILendingPool {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

interface IWETHGateway {
    function depositETH(
        address lendingPool,
        address onBehalfOf,
        uint16 referralCode
    ) external payable;

    function withdrawETH(
        address lendingPool,
        uint256 amount,
        address onBehalfOf
    ) external;
}

interface IUniswapRouter is ISwapRouter {
    function refundETH() external payable;
}

contract LendingProtocol is  Ownable, InnerMath {
     using Math for uint256;

    uint256 public totalBorrowed;
    uint256 public totalReserve;
    uint256 public totalDeposit;
    uint256 public maxLTV = 4; // 1 = 20%
    uint256 public ethTreasury;
    uint256 public totalCollateral;
    uint256 public baseRate = 20000000000000000;
    uint256 public fixedAnnuBorrowRate = 300000000000000000;

    ILendingPool public constant aave =
        ILendingPool(0x56Ab717d882F7A8d4a3C2b191707322c5Cc70db8);//lendingPool
    IWETHGateway public constant wethGateway =
        IWETHGateway(0xd5B55D3Ed89FDa19124ceB5baB620328287b915d);//according to GPT
    IERC20 public constant dai =
        IERC20(0x77FDe93fEe5fe272dC17d799cb61447431E6Eba2);//dai
    IERC20 public constant aDai =
        IERC20(0x2B101eFBB4dFf1fbB8f87f02C560Fb8AC773aFC5);//aave fantom dai
    IERC20 public constant aWeth =
        IERC20(0x0e426e6e6B226D8bd566e417b90411Dcf14DF861);//aave fantom weth
    AggregatorV3Interface internal constant priceFeed =
        AggregatorV3Interface(0xEE4bC42157cf65291Ba2FE839AE127e3Cc76f741);//?
    IUniswapRouter public constant uniswapRouter =
        IUniswapRouter(0xa6AD18C2aC47803E193F75c3677b14BF19B94883);//?
    IERC20 private constant weth =
        IERC20(0xc8c0Cf9436F4862a8F60Ce680Ca5a9f0f99b5ded);//weth

    BondToken public bondToken;

    mapping(address => uint256) private usersCollateral;
    mapping(address => uint256) private usersBorrowed;

    constructor(address initialOwner) Ownable(initialOwner){
        
        bondToken=new BondToken();
    }

    function bondAsset(uint256 _amount) external {
        dai.transferFrom(msg.sender, address(this), _amount);
        _sendDaiToAave(_amount);
        uint256 bondsToMint = InnerMath.getExp(_amount, getExchangeRate());
        totalDeposit += _amount;
        bondToken.mint(msg.sender, bondsToMint);
    }

    function unbondAsset(uint256 _amount) external {
        require(_amount <= bondToken.balanceOf(msg.sender), "Not enough bonds!");
        uint256 daiToReceive = InnerMath.mulExp(_amount, getExchangeRate());
        totalDeposit -= daiToReceive;
        bondToken.burn(msg.sender,_amount);
        _withdrawDaiFromAave(daiToReceive);
    }

    function addCollateral() external payable {
        require(msg.value != 0, "Cant send 0 ethers");
        usersCollateral[msg.sender] += msg.value;
        totalCollateral += msg.value;
        _sendWethToAave(msg.value);
    }

    function removeCollateral(uint256 _amount) external {
        uint256 wethPrice = uint256(_getLatestPrice());
        uint256 collateral = usersCollateral[msg.sender];
        require(collateral > 0, "Dont have any collateral");
        uint256 borrowed = usersBorrowed[msg.sender];
        uint256 collateralInUSDC=InnerMath.mulExp(collateral, wethPrice);
        (bool status,uint256 amountLeft ) = collateralInUSDC.trySub(borrowed);
        uint256 amountToRemove = InnerMath.mulExp(_amount, wethPrice);
        require(amountToRemove < amountLeft, "Not enough collateral to remove");
        usersCollateral[msg.sender] -= _amount;
        totalCollateral -= _amount;
        _withdrawWethFromAave(_amount);
        payable(msg.sender).transfer(_amount);
    }

    function borrow(uint256 _amount) external {
        require(_amount <= _borrowLimit(), "No collateral enough");
        usersBorrowed[msg.sender] += _amount;
        totalBorrowed += _amount;
        _withdrawDaiFromAave(_amount);
    }

    function repay(uint256 _amount) external {
        require(usersBorrowed[msg.sender] > 0, "Doesnt have a debt to pay");
        dai.transferFrom(msg.sender, address(this), _amount);
        (uint256 fee, uint256 paid) = calculateBorrowFee(_amount);
        usersBorrowed[msg.sender] -= paid;
        totalBorrowed -= paid;
        totalReserve += fee;
        _sendDaiToAave(_amount);
    }

    function calculateBorrowFee(uint256 _amount)
        public
        view
        returns (uint256, uint256)
    {
        uint256 borrowRate = _borrowRate();
        uint256 fee = InnerMath.mulExp(_amount, borrowRate);
        (bool status,uint256 paid) = _amount.trySub(fee);
        return (fee, paid);
    }

    function liquidation(address _user) external onlyOwner {
        uint256 wethPrice = uint256(_getLatestPrice());
        uint256 collateral = usersCollateral[_user];
        uint256 borrowed = usersBorrowed[_user];
        uint256 collateralToUsd = InnerMath.mulExp(wethPrice, collateral);
        if (borrowed > InnerMath.percentage(collateralToUsd, maxLTV)) {
            _withdrawWethFromAave(collateral);
            uint256 amountDai = _convertEthToDai(collateral);
            totalReserve += amountDai;
            usersBorrowed[_user] = 0;
            usersCollateral[_user] = 0;
            totalCollateral -= collateral;
        }
    }

    function getExchangeRate() public view returns (uint256) {
        if (bondToken.totalSupply() == 0) {
            return 1000000000000000000;
        }
        uint256 cash = getCash();
        (bool status,uint256 num) = cash.tryAdd(totalBorrowed);
        if(status)
        (status, num) = num.tryAdd(totalReserve);
        return InnerMath.getExp(num, bondToken.totalSupply());
    }

    function getCash() public view returns (uint256) {
        (bool status,uint256 result)= totalDeposit.trySub(totalBorrowed);
        if(status)
          return result;
        else
          return 0;
    }

    function harvestRewards() external onlyOwner {
        uint256 aWethBalance = aWeth.balanceOf(address(this));
        if (aWethBalance > totalCollateral) {
            (bool status,uint256 rewards) = aWethBalance.trySub(totalCollateral);
            if(status)
            _withdrawWethFromAave(rewards);
            ethTreasury += rewards;
        }
    }

    function convertTreasuryToReserve() external onlyOwner {
        uint256 amountDai = _convertEthToDai(ethTreasury);
        ethTreasury = 0;
        totalReserve += amountDai;
    }

    function _borrowLimit() public view returns (uint256) {
        uint256 amountLocked = usersCollateral[msg.sender];
        require(amountLocked > 0, "No collateral found");
        uint256 amountBorrowed = usersBorrowed[msg.sender];
        uint256 wethPrice = uint256(_getLatestPrice());
        (bool status,uint256 amountLeft) = InnerMath.mulExp(amountLocked, wethPrice).trySub(
            amountBorrowed
        );
        return InnerMath.percentage(amountLeft, maxLTV);
    }

    function _sendDaiToAave(uint256 _amount) internal {
        dai.approve(address(aave), _amount);
        aave.deposit(address(dai), _amount, address(this), 0);
    }

    function _withdrawDaiFromAave(uint256 _amount) internal {
        aave.withdraw(address(dai), _amount, msg.sender);
    }

    function _sendWethToAave(uint256 _amount) internal {
        wethGateway.depositETH{value: _amount}(address(aave), address(this), 0);
    }

    function _withdrawWethFromAave(uint256 _amount) internal {
        aWeth.approve(address(wethGateway), _amount);
        wethGateway.withdrawETH(address(aave), _amount, address(this));
    }

    function getCollateral() external view returns (uint256) {
        return usersCollateral[msg.sender];
    }

    function getBorrowed() external view returns (uint256) {
        return usersBorrowed[msg.sender];
    }

    function balance() public view returns (uint256) {
        return aDai.balanceOf(address(this));
    }

    function _getLatestPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price * 10**10;
    }

    function _utilizationRatio() public view returns (uint256) {
        return InnerMath.getExp(totalBorrowed, totalDeposit);
    }

    function _interestMultiplier() public view returns (uint256) {
        uint256 uRatio = _utilizationRatio();
        (bool status,uint256 num) = fixedAnnuBorrowRate.trySub(baseRate);
        return InnerMath.getExp(num, uRatio);
    }

    function _borrowRate() public view returns (uint256) {
        uint256 uRatio = _utilizationRatio();
        uint256 interestMul = _interestMultiplier();
        uint256 product = InnerMath.mulExp(uRatio, interestMul);
        (bool status, uint256 result)= product.tryAdd(baseRate);
        return result;
    }

    function _depositRate() public view returns (uint256) {
        uint256 uRatio = _utilizationRatio();
        uint256 bRate = _borrowRate();
        return InnerMath.mulExp(uRatio, bRate);
    }

     function getBondTokenAddress() public view returns (address) {
        return address(bondToken);
    }

    function _convertEthToDai(uint256 _amount) internal returns (uint256) {
        require(_amount > 0, "Must pass non 0 amount");

        uint256 deadline = block.timestamp + 15; // using 'now' for convenience
        address tokenIn = address(weth);
        address tokenOut = address(dai);
        uint24 fee = 3000;
        address recipient = address(this);
        uint256 amountIn = _amount;
        uint256 amountOutMinimum = 1;
        uint160 sqrtPriceLimitX96 = 0;

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams(
                tokenIn,
                tokenOut,
                fee,
                recipient,
                deadline,
                amountIn,
                amountOutMinimum,
                sqrtPriceLimitX96
            );

        uint256 amountOut = uniswapRouter.exactInputSingle{value: _amount}(
            params
        );
        uniswapRouter.refundETH();
        return amountOut;
    }

    receive() external payable {}

    fallback() external payable {}
}