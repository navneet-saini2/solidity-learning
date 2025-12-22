// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    mapping(bytes32 => mapping(address => bool)) public hasRole;

    error NotAdmin();

    modifier onlyRole(bytes32 _role) {
        if (!hasRole[_role][msg.sender]) {
            revert NotAdmin();
        }
        _;
    }

    function grantRole(
        bytes32 _role,
        address _user
    ) public onlyRole(ADMIN_ROLE) {}
}
