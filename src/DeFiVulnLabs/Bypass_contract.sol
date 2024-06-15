// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract Target{
    function isContract(address account) public view returns(bool){
        uint size=0;
        assembly{
            size:=extcodesize(account)
        }
        return size>0;
    }

    bool public pwned;
    function protected()external {
        require(isContract(this),"contract is not allowed");
        pwned=true;

    }
}

contract Attack{
    bool 
}
