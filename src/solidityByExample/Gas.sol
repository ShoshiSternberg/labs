//SPDX-License-Indentifier:MIT
pragma solidity ^0.8.24;

contract Gas{
    uint public i=0;

    function forever()public{
        while(true){
            i+=1;
        }
    }
}