//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract Payroll {
    address[] public employeeList;
    mapping(address => bool) public isEmployed;
    address public boss;

    error NotBoss();
    error AlreadyEmployed();

    constructor() {
        boss = msg.sender;
    }

    modifier onlyBoss() {
        if (msg.sender != boss) {
            revert NotBoss();
        }
        _;
    }
    modifier notAlreadyEmployed(address _worker) {
        if (isEmployed[_worker]) {
            revert AlreadyEmployed();
        }
        _;
    }

    function addEmployee(
        address _worker
    ) public onlyBoss notAlreadyEmployed(_worker) {
        employeeList.push(_worker);
        isEmployed[_worker] = true;
    }

    function isItPayday() public view returns (bool) {
        return (block.timestamp % 2 == 0);
    }

    function totalEmployees() public view returns (uint256) {
        return employeeList.length;
    }
}
