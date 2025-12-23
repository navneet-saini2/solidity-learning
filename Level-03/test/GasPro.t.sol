//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "forge-std/Test.sol";
import "../src/GasPro.sol";

contract GasProTest is Test {
    GasPro gasPro;

    function setUp() public {
        gasPro = new GasPro();
    }

    function test_RevertWhen_CallerIsNotOwner() public {
        address notOwner = address(0x1234);

        // 1. Pretend to be the hacker
        vm.prank(notOwner);

        // 2. Tell Foundry to expect the "NotOwner" error
        vm.expectRevert(GasPro.NotOwner.selector);

        // 3. Call the function that HAS the modifier
        gasPro.incrementCount();
    }
}
