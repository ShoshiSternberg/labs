// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Variables{
    uint public i=7;
    string public text="hello";

    function doSomething()public{
        uint number=23;

        uint time=block.timestamp;
        address owner=msg.sender;

    }
}