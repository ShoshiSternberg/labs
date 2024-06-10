// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EtherUnits{
    uint public oneWei=1 wei;
    bool public isOneWei=(oneWei==1);
    uint public oneGWei=1 gwei;
    bool public isOneGWei=(oneGWei==1e9);
    uint public oneEther=1 ether;
    bool public isOneEther=(oneEther==1e18);


}