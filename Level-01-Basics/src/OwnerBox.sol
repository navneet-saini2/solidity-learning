//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract OwnerBox {
    uint256 myNumber;
    address public owner;

    error NotOwner();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    function setNumber(uint256 _myNumber) public onlyOwner {
        myNumber = _myNumber;
    }

    function addFive() public {
        myNumber = myNumber + 5;
    }

    function getNumber() public view returns (uint256) {
        return myNumber;
    }
}
