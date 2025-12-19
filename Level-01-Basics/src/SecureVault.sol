//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract SecureVault {
    mapping(address => uint256) public balances;

    error NotEnoughBalance(uint256 available, uint256 required);
    error TransferFailed();

    function deposit() public payable {
        // msg.value is the money coming IN
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amt) public {
        // 1. CHECK: Look at the mapping (their saved balance)
        if (_amt > balances[msg.sender]) {
            revert NotEnoughBalance(balances[msg.sender], _amt);
        }

        // 2. EFFECT: Update the mapping BEFORE the transfer
        balances[msg.sender] -= _amt;

        // 3. INTERACTION: Send the money
        (bool success, ) = msg.sender.call{value: _amt}("");

        // 4. SECURITY: Always check the 'success' boolean!
        if (!success) {
            revert TransferFailed();
        }
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
