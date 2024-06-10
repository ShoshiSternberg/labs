// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract BackdoorAssembly_LotteryGameTest is Test{
    LotteryGame public game= new LotteryGame();

    constructor(){
        game=new LotteryGame();
    }

    function testLotteryGame() public {

        address alice=vm.addr(1);
        address bob=vm.addr(2);

        vm.startPrank(alice);
        game.pickWinner(alice);
        game.getWinner();

        vm.stopPrank();
        game.pickWinner(bob);
        game.getWinner();        

    }
}


contract LotteryGame{
    uint public prize=1000;
    address public winner;
    address public admin=msg.sender;

    modifier safeChack(){
        if(msg.sender==refree())
        _;
        else getWinner();

    }

    function refree()public view returns(address user){
        assembly {
            user:=sload(2)
        }
    }

    function pickWinner(address random) public safeChack {
        assembly {
            sstore(2,random)
        }
        winner=random;
    }

    function getWinner() public view returns(address){
        console.log(winner);
        return winner;
    }
}