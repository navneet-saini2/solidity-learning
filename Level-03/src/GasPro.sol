// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.30;

contract GasPro {
    uint256 public count;
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

    function incrementCount() public onlyOwner {
        count++;
    }

    function fastIncrement(uint256 x) public pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }
}
