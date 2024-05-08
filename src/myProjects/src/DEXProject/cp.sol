// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {MyERC20} from "./erc20.sol";
import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";

contract CP {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint public reserve0 = 0;
    uint public reserve1 = 0;

    uint public totalSupply;

    mapping(address => uint) public balances;

    constructor(address t0, address t1) {
        token0 = IERC20(t0);
        token1 = IERC20(t1);
    }

    function mint(address to, uint amount) private {
        balances[to] += amount;
        totalSupply += amount;
    }

    function burn(address from, uint amount) private {
        balances[from] -= amount;
        totalSupply -= amount;
    }

    function swap(
        address addIn, //USDC
        uint amountIn //5
    ) external returns (uint amountOut) {
        require(
            addIn == address(token0) || addIn == address(token1),
            "AMM3-invalid-token"
        );
        require(amountIn > 0, "AMM3-zero-amount");
        if (reserve0 == 0 && reserve1 == 0)
            reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
        
        bool isToken0 = addIn == address(token0);
        (
            IERC20 tokenIn, //USDC
            IERC20 tokenOut, //TURKISH
            uint reserveIn, //21
            uint reserveOut //42
        ) = isToken0
                ? (token0, token1, reserve0, reserve1)
                : (token1, token0, reserve1, reserve0);

        tokenIn.transferFrom(msg.sender, address(this), amountIn);

        uint amountInWithFee = (amountIn * 997) / 1000;
        amountOut =
            (reserveOut * amountInWithFee) /
            (reserveIn + amountInWithFee);
        console.log(amountInWithFee, "  ", amountOut);
        tokenOut.transfer(msg.sender, amountOut);

        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
    }

    function addLiquidity(
        uint amount0,
        uint amount1
    ) external returns (uint shares) {
        token0.transferFrom(msg.sender, address(this), amount0);
        token1.transferFrom(msg.sender, address(this), amount1);
        console.log("reserve0 ",token0.balanceOf(address(this)));
        console.log("reserve1 ",token1.balanceOf(address(this)));
        console.log("amount0 ",amount0, "amount1 ",amount1);
        if (reserve0 > 0 || reserve1 > 0)
            require(reserve0 * amount1 == reserve1 * amount0, "x/y != dx/dy");

        if (totalSupply == 0) {
            shares = sqrt(amount1 * amount0);
        } else {
            shares = min(
                (amount0 * totalSupply) / reserve0,
                (amount1 * totalSupply) / reserve1
            );
        }

        require(shares > 0, "shares = 0");
        mint(msg.sender, shares);
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
    }

    // fucntion removeLiquidity(uint _shares) external returns(uint amount0,uint amount1){

    // }

    function sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }


    function min(uint x, uint y) private pure returns(uint ){
        return x<y?x:y;

    }
}
