// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/console.sol";

contract DistributeTokens {
    address[] public arr2;

    constructor() {}

    function add(address user) public {
        arr2.push(user);
    }

    function distributeTokens(uint256 amount) public payable{
        console.log(address(msg.sender).balance);
        console.log(arr2.length);
        console.log(amount);
        console.log("msg.sender", msg.sender,"arr2[i]",arr2[3]);
        uint amountToMember=amount / arr2.length;
         console.log(amountToMember);
        for (uint256 i = 0; i < arr2.length; i++) {
            console.log("msg.sender", msg.sender,"arr2[i]",arr2[i]);
            payable(arr2[i]).transfer(amountToMember); 
            //payable(arr2[i]).transferFrom(msg.sender, amount / arr2.length); 
            //payable(msg.sender).transfer(arr2[i],amount / arr2.length)       ;    
        }
    }
}
