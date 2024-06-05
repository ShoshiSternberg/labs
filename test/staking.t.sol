// SPDX-License-Identifier: MIT
// https://solidity-by-example.org/defi/staking-rewards/
// Code is a stripped down version of Synthetix
pragma solidity ^0.8.24;
import "../src/stakingProject/staking.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {RewardsToken} from "../src/myStaking/rewardsToken.sol";
contract StakingRewardsTest{
   uint constant WAD=10**18;

   StakingRewards staking;

   RewardsToken rt;
   RewardsToken st;

   // address user1=vm.addr(1);
   // address user2=vm.addr(2);
   // address user3=vm.addr(3);
   function setUp() public {
    rt=new RewardsToken(1000*WAD);
    st=new RewardsToken(1000*WAD);
    staking= new StakingRewards(address(st),address(rt));
    rt.mint(address(staking),100000*WAD);
   //  st.mint(user1,1000*WAD);

   }
   function testStake()public{
   //  vm.StartPrank(user1);
   //  st.approve(address(staking));
   //  staking.stake(100*WAD);
   //  vm.stopPrank();
   //  vm.StartPrank(user2);
   //  st.approve(address(staking));
   //  staking.stake(100*WAD);
   //  vm.stopPrank();
   //  vm.StartPrank(user1);
   //  console.log(block.timestamp);
   //  vm.warp(10000);
   //  staking.withdraw(5*WAD);
   //  console.log(block.timestamp);
   //  console.log(staking.lastTime());
   //  console.log(staking.rate());
   //  console.log(staking.reward());
   //  vm.warp(10000000);
   //  staking.withdraw(1*WAD);
   //  console.log(staking.reward());
   }
}