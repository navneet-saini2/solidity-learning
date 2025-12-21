// upgrade it with events

//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract ObservableVault {
    mapping(address => uint256) private balances;

    event FundsDeposited(address indexed user, uint256 amount);
    event FundsWithdrawn(address indexed user, uint256 amount);

    error NotEnoughBalance(uint256 available, uint256 required);
    error TransactionFailed();

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public {
        if (_amount > balances[msg.sender]) {
            revert NotEnoughBalance(balances[msg.sender], _amount);
        }

        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        if (!success) {
            revert TransactionFailed();
        }
        emit FundsWithdrawn(msg.sender, _amount);
    }

    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
