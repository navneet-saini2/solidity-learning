// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

// PARENT
contract Ownable {
    address public owner;
    error NotOwner();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
}

// CHILD
contract VaultV2 is Ownable {
    error WithdrawFailed();

    // Notice: No need to pass _amount if we want to withdraw EVERYTHING
    function withdrawAll() public onlyOwner {
        uint256 amount = address(this).balance;

        // Using .call instead of .transfer
        (bool success, ) = owner.call{value: amount}("");
        if (!success) revert WithdrawFailed();
    }

    // Required to receive money in Foundry/Remix tests
    receive() external payable {}
}
