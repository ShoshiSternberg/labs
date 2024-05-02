  // SPDX-License-Identifier: UNLICENSED
  pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/console.sol";
// import "foundry-huff/HuffDeployer.sol";
import {SimpleStakingProject} from "../src/myStaking/simple_staking_project.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleStakingProjectTest is Test {


    SimpleStakingProject public staking;

    function setUp() public {
        staking = new SimpleStakingProject();
    }

    
      receive() external payable {}
    
    //@test depost staking tokens in the staking pool, in certain date
     function testDeposit() public {
      
         staking.deposit(200);      
      
     }
     

     function testGetRewards()public{
        staking.getRewards(1);
     }

}  

    

    

