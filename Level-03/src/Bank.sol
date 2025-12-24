// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Bank {
    address public owner;
    bool private locked;
    mapping(address => uint256) public balances;

    error NotOwner();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (owner != msg.sender) revert NotOwner();
        _;
    }

    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    // Use 'calldata' for arrays in input to save even MORE gas
    function getTotalAssets(
        address[] calldata users
    ) external view onlyOwner returns (uint256) {
        uint256 total = 0;
        uint256 len = users.length;
        for (uint256 i = 0; i < len; ) {
            total += balances[users[i]]; // Check bank balance, not wallet balance
            unchecked {
                i++;
            }
        }
        return total;
    }

    // No parameters needed, msg.value handles the money
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public noReentrant {
        require(balances[msg.sender] >= _amount, "Low balance");

        // CEI Pattern: Effect happens BEFORE interaction
        balances[msg.sender] -= _amount;

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function getBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }
}
