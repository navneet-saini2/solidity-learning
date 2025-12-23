//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "forge-std/Test.sol";
import "../src/GasPro.sol";

contract GasProTest is Test {
    GasPro gasPro;

    function setUp() public {
        gasPro = new GasPro();
    }

    // 1. Existing Security Test
    function test_RevertWhen_CallerIsNotOwner() public {
        address notOwner = address(0x1234);

        vm.prank(notOwner);
        vm.expectRevert(GasPro.NotOwner.selector);

        gasPro.incrementCount();
    }

    // 2. Added Fuzz Test (Optimization & Math Safety)
    function testFuzz_FastIncrement(uint256 randomX) public {
        // We tell Foundry: "Ignore the absolute maximum value to prevent overflow"
        vm.assume(randomX < type(uint256).max);

        // Call the function from your src/GasPro.sol
        uint256 result = gasPro.fastIncrement(randomX);

        // Verify the math is correct across hundreds of random inputs
        assertEq(result, randomX + 1);
    }
}
