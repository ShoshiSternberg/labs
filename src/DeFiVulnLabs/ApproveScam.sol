// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract approveScamTest is Test{
    ERC20 public erc20Contract;
    address alice=vm.addr(1);
    address eve=vm.addr(2);
    constructor(){
        erc20Contract=new ERC20();
        erc20Contract._mint(alice,200000);
        erc20Contract._mint(eve,200000);
    }
    
    function testTransfer() public{
            vm.prank(alice);
            erc20Contract.approve(address(erc20Contract),2000);
            erc20Contract.transfer(eve, 2000);
            console.log(
                    "Dou to the approve action alice did, the contract can spend funds of alice and transfer it to eve"
            );
    }

    receive()  external payable{}


}

interface IERC20{
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address owner,address spender) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external payable returns(bool);
    function transferFrom(address account, address to, uint256 amount) external payable returns(bool);
    function approve(address spender, uint256 amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256);
    event Approval(address indexed owner,address indexed spender, uint256);
}

contract ERC20 is IERC20{
    uint256 public _totalSupply=0;
    uint8 public decimals=18;
    string public name="example";
    string public symbol="exmpl";
    mapping(address=>mapping(address=>uint)) public allowances;
    mapping(address=>uint) public balances;

    function totalSupply() external view returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address account) external view returns(uint256){
        return balances[account];
    }

    function allowance(address owner, address spender) external view returns(uint256){
        return allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) external payable returns(bool){
        allowances[msg.sender][address(this)]-=amount;
        balances[msg.sender]-=amount;
        balances[recipient]+=amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address account, address to, uint256 amount) external payable returns(bool){
        allowances[account][address(this)]-=amount;
        balances[account]-=amount;
        balances[to]+=amount;
        emit Transfer(account, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns(bool){
        allowances[msg.sender][spender]+=amount;
        emit Approval(msg.sender, spender,amount);
        return true;

    }

    function _mint(address to, uint amount)external // internal 
    returns(bool){
        _totalSupply+=amount;
        balances[to]+=amount;
        return true;
    }

    function _burn(address from, uint amount) external //internal 
    returns(bool){
        _totalSupply-=amount;
        balances[from]-=amount;
        return true;
    }
}