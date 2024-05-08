// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleStakingProject {
    ERC20 public immutable stakingToken;
    ERC20 public immutable rewardsToken;

    

    mapping(address=>User) public users ;

    constructor() {
        rewardsToken.mint(address(this),1000000);
        
    }

    function deposit( uint256 amount) public{
        if(!users[msg.sender].isValue)
            users[msg.sender]=new User(msg.sender);
        users[msg.sender].deposit(amount);
        stakingToken.transferFrom(msg.sender,address(this),amount);

    }


    function withdraw(uint256 amount)public returns(uint256){
        require(users[msg.sender].isValue);
        uint256 realAmount=calculate_rewards(msg.sender)>amount?amount:calculate_rewards(msg.sender);
        rewardsToken.transferFrom(address(this),msg.sender,realAmount);
        users[msg.sender].deposit((-1)*realAmount);
        return realAmount;
    }


    function calculateRewards(address user) public pure returns(uint){
    //by the balance of the user before 7 days I and the total supply in the pool I can calculate the ratio of the user in the pool.
    //now we know the ratio, the reward is the total number of tokens divided by the ratio.abi
        uint256 rewards= rewardsToken.totalSupply()/get_ratio(user);

    }

    function getRatio(address user) public pure returns(uint){
        uint256 totalSupply= stakingToken.totalSupply();
        uint256 ratio= totalSupply/users[address].totalDeposits();
    }


    
}


contract User{
    address public addr ;
    uint256 public num_stakes =0; 
    mapping(uint=>date) public stake_dates;
    mapping(date=>uint256) public stakes_amount;    
    uint public beginningDate;


    constructor(address addr){
        addr=addr;        
    }


    function deposit(uint256 amount) public {
        stake_dates[num_stakes++]=block.timestamp;
        stakes_amount[block.timestamp]=amount;

    }

    function wasBeforeLastWeek(uint256 date) public view returns (bool) {
        uint256 SECONDS_IN_WEEK = 604800;//7 days * 24 hours * 60 minutes * 60 seconds
        uint256 oneWeekAgo = block.timestamp - SECONDS_IN_WEEK;
        return oneWeekAgo > date;
    }

    function totalDeposits() view public returns(uint256){
        uint256 balance=0;

        for(uint i=0;i<num_stakes;i++){

            if(wasBeforeLastWeek(stake_dates[i])==true&&stake_dates[i]>beginningDate)
                  balance+=stakes_amount[stake_dates[i]];
                       
        }

        return balance;
    }

}