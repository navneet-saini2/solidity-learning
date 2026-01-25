// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {AccessControl} from "../src/AccessControl.sol";

contract AccessControlTest is Test {
    AccessControl accessControl;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        // Test contract deploys it and is the original admin
        accessControl = new AccessControl();

        // Test contract grants 'owner' the admin role
        accessControl.grantRole(accessControl.ADMIN_ROLE(), owner);
    }

    function test_Revert_WhenNonAdminCallsGrantRole() public {
        // Cache the role to avoid making an external call inside the prank/expectRevert window
        bytes32 adminRole = accessControl.ADMIN_ROLE();

        // We want 'user' (non-admin) to fail
        vm.prank(user);
        vm.expectRevert(AccessControl.NotAdmin.selector);

        accessControl.grantRole(adminRole, user);
    }

    function test_AdminCanGrantRole() public {
        bytes32 adminRole = accessControl.ADMIN_ROLE();

        vm.prank(owner);
        accessControl.grantRole(adminRole, user);

        assertTrue(accessControl.hasRole(adminRole, user));
    }
}
