//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract SecureBank {
    bool private locked; // Defaults to false

    error NoReentrancyAllowed();

    modifier noReentrant() {
        // 1. Check: If it is ALREADY locked, someone is trying to re-enter!
        if (locked) {
            revert NoReentrancyAllowed();
        }

        // 2. Lock: Set it to true before the function runs
        locked = true;

        // 3. Execute: Run the function code
        _;

        // 4. Unlock: Set it back to false so it can be used again
        locked = false;
    }

    mapping(address => uint256) public balances;

    // Now this function is "Bulletproof"
    function withdraw(uint256 _amount) public noReentrant {
        require(balances[msg.sender] >= _amount, "Low balance");

        balances[msg.sender] -= _amount;

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }
}
