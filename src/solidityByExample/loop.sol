//SPDX-License-Indentifier:MIT
pragma solidity ^0.8.24;

contract Loop{
    function loop() public{
        uint i=0;
        for(i=0;i<10;i++){
            if(i==4)
            continue;
            if(i==7)
            break;
        }

        uint x=1;
        while(i<17){
            i++;
            x+=i;
        }
    }
}