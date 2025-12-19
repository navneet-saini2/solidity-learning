//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract DeFi {
    struct Account {
        uint256 balance;
        bool isFrozen;
    }
    address public owner;
    mapping(address => Account) public vault;

    error AccountFrozen(address user);
    error InsufficientFunds(uint256 available, uint256 required);
    error NotOwner();

    constructor() {
        owner = msg.sender;
    }

    modifier notFrozen() {
        if (vault[msg.sender].isFrozen) {
            revert AccountFrozen(msg.sender);
        }
        _;
    }
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    function deposit(uint256 _amt) public notFrozen {
        Account storage userAcc = vault[msg.sender];
        userAcc.balance += _amt;
    }

    function withdraw(uint256 _amt) public notFrozen {
        Account storage userAcc = vault[msg.sender];
        if (_amt > userAcc.balance) {
            revert InsufficientFunds(userAcc.balance, _amt);
        }
        userAcc.balance -= _amt;
    }

    function freezeUser(address _target) public onlyOwner {
        vault[_target].isFrozen = true;
    }
}
