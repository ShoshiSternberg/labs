// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ArrayDeletionTest is Test{
    ArrayDeletionWithBugs public buggyContract=new ArrayDeletionWithBugs();
    FixedArrayDeletion public fixedContract=new FixedArrayDeletion();

    function testDeleteFromArrayBuggy() public {
        
        //uint256[] storage myArray = [1, 2, 3, 4, 5];
        uint256[] memory myArray = new uint256[](5);
        myArray[0] = 1;
        myArray[1] = 2;
        myArray[2] = 3;
        myArray[3] = 4;
        myArray[4] = 5;
        myArray= buggyContract.deleteElement(myArray, 2);
        printArray(myArray);
        console.log("length");
        console.log(myArray.length);
    }

    function testDeleteFromArrayFixed() public {
        
        //uint256[] storage myArray = [1, 2, 3, 4, 5];
        uint256[] memory myArray = new uint256[](5);
        myArray[0] = 1;
        myArray[1] = 2;
        myArray[2] = 3;
        myArray[3] = 4;
        myArray[4] = 5;
        myArray=fixedContract.deleteElement(myArray, 2);
        printArray(myArray);
        console.log("length");
        console.log(myArray.length);
    }

    receive () external payable{}

    function printArray(uint256 [] memory arr) internal {
        for(uint i=0;i<arr.length;i++){
            console.log(arr[i]);
        }
    }
}

contract ArrayDeletionWithBugs{
    function deleteElement(uint256 [] memory arr,uint256 index) public returns(uint256 [] memory){
        require(index<arr.length,"out of range");
        delete arr[index];
        return arr;

    }
}

contract FixedArrayDeletion{
    function deleteElement(uint256 [] memory arr, uint256 index) public returns(uint256 [] memory){
        require(index<arr.length,"out of range");
        uint256[] memory myArray = new uint256[](arr.length-1);
        for(uint i=0; i<index;i++){
            myArray[i]=arr[i];
        }
        for(uint i=index;i<arr.length-1;i++){
            myArray[i]=arr[i+1];
        }       
                
        return myArray;
    }
}