// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Reentrancy {
    mapping(address => uint256) public balances;
    bool private locked;

    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    /*
    The Golden Rule: CEI Pattern

    Checks: (Check require statements).
    Effects: (Update the state/balance FIRST).
    Interactions: (Send the money LAST).
    */

    function withdraw() public {
        uint256 amount = balances[msg.sender];

        balances[msg.sender] = 0;

        // 1. Interaction (DANGEROUS: Sending money before updating balance)
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // 2. Effect (Too late! The hacker already re-entered)
        // balances[msg.sender] = 0;
    }
}
