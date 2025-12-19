//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract SalarySplitter {
    address public boss;
    address public emp1;
    address public emp2;

    error NotBoss();
    error TransferFailed();

    constructor() {
        boss = msg.sender;
    }

    modifier onlyBoss() {
        if (msg.sender != boss) {
            revert NotBoss();
        }
        _;
    }

    function setEmployees(address _e1, address _e2) public onlyBoss {
        emp1 = _e1;
        emp2 = _e2;
    }

    function depositFunds() public payable {}

    function payout() public payable {
        uint256 total = address(this).balance;
        if (total > 0) {
            uint256 amountPerPerson = total / 2;

            // 2025 BEST PRACTICE: Use .call instead of .transfer
            (bool success1, ) = payable(emp1).call{value: amountPerPerson}("");
            (bool success2, ) = payable(emp2).call{value: amountPerPerson}("");

            if (!success1 || !success2) revert TransferFailed();
            /*
            payable(emp1).transfer(amountPerPerson);
            payable(emp2).transfer(amountPerPerson);
            */
        }
    }
}
