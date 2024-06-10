// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ViewAndPure{
    uint x=1;
    function addView() public returns(uint){
        return x+1;
    }

    function addPure(uint xa, uint y)public returns(uint){
        return xa+y;
    }
}