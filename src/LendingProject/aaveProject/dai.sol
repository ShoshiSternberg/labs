// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dai is ERC20 {
    constructor() ERC20("DaiToken", "DAI") {
        
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address account,uint value) external{
        _burn(account,value);
    }
}