//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract UserLedger {
    // uint256 balance; [its for single variable]
    mapping(address => uint256) public balances; // mapping is use for multiple values

    error LimitExceeded(uint256 attempted, uint256 max);

    modifier underLimit(uint256 _amount) {
        if (_amount > 1000) {
            revert LimitExceeded(_amount, 1000);
        }
        _;
    }

    function addBalance(uint256 _amount) public underLimit(_amount) {
        balances[msg.sender] += _amount;
    }

    function checkBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }
}
