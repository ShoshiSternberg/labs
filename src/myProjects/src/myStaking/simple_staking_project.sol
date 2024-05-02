// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/console.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {StakingToken} from "./stakingToken.sol";
import {RewardsToken} from "./rewardsToken.sol";

contract SimpleStakingProject {
    StakingToken public immutable stakingToken;
    RewardsToken public immutable rewardsToken;

    event consoleLog(string);
    event consoleLogInt(uint256);

    mapping(address => User) public users;

    constructor() {
        rewardsToken=new RewardsToken(1000000);
        stakingToken=new StakingToken(0);

        //rewardsToken.mint(address(this), 1000000);        
    }   

    receive() external payable {}

    //@dev deposit stakingTokens in the staking pool
    function deposit(uint256 amount) public {
        emit consoleLogInt(rewardsToken.totalSupply());
        // if (!users[msg.sender].isExist())
        //     users[msg.sender] = new User(msg.sender);
        users[msg.sender]=new User(msg.sender);
        users[msg.sender].deposit(amount);
        stakingToken.transferFrom(msg.sender, address(this), amount);        
    }

    //@dev withdraw staked tokens from the staking pool
    function withdraw(uint amount) public returns(uint256){
        //when the user wants to withdraw his staked tokens, we just insert new deposit on the same value but negative.       
        int negativeAmount = int(amount) * -1;// Equivalent to realAmount * -1
        deposit(uint(negativeAmount)); 
        return stakingToken.balanceOf(msg.sender);
    }

    //@withdraw rewards from the rewards pool
    function getRewards(uint256 amount) public returns (uint256) {
        require(users[msg.sender].addr()!=address(0x0),"Only a user who has deposited money is eligible to withdraw rewards");
        uint256 realAmount = calculateRewards(msg.sender) > amount
        ? amount
        : calculateRewards(msg.sender);
    
        rewardsToken.transferFrom(address(this), msg.sender, realAmount);
            

    return realAmount;
    }

    function calculateRewards(address user) public view returns (uint) {
        //by the balance of the user before 7 days I and the total supply in the pool I can calculate the ratio of the user in the pool.
        //now we know the ratio, the reward is the total number of tokens divided by the ratio.abi
        uint256 rewards = rewardsToken.totalSupply() / getRatio(user);
        return rewards;
    }

    function getRatio(address user) public view returns (uint) {
        uint256 totalSupply = stakingToken.totalSupply();
        uint256 ratio = totalSupply / users[user].totalDeposits();
        return ratio;
    }
}

contract User {
    address public addr=address(0x0);
    uint256 public num_stakes = 0;
    mapping(uint => uint256) public stake_dates;
    mapping(uint256 => uint256) public stakes_amount;
    uint public beginningDate;


    event consoleLog(string);
    event consoleLogInt(uint256);

    constructor(address add) {
        addr = add;
    }

    function isExist()public view returns(bool){
        if (addr==address(0x0))
        return false;
        return true;
    }

    function deposit(uint256 amount) public {
        stake_dates[num_stakes++] = block.timestamp;
        stakes_amount[block.timestamp] = amount;
    }

    function wasBeforeLastWeek(uint256 date) public view returns (bool) {
        uint256 SECONDS_IN_WEEK = 604800; //7 days * 24 hours * 60 minutes * 60 seconds
        uint256 oneWeekAgo = block.timestamp - SECONDS_IN_WEEK;
        return oneWeekAgo > date;
    }

    function totalDeposits() public view returns (uint256) {
        uint256 balance = 0;

        for (uint i = 0; i < num_stakes; i++) {
            if (
                wasBeforeLastWeek(stake_dates[i]) == true &&
                stake_dates[i] > beginningDate
            ) balance += stakes_amount[stake_dates[i]];
        }

        return balance;
    }
}
