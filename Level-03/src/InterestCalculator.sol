//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract InterestCalculator {
    uint256 public constant SCALE = 1e18;

    // This returns the interest scaled by 1e18 so no precision is lost

    function getInterest(uint256 _amount) public pure returns (uint256) {
        // We multiply by SCALE to keep the "decimals" inside the big number
        return (_amount * 5 * SCALE) / 100;
    }

    // Example: If you pass 10, it returns 0.5 * 10^18
    // The frontend then divides by 1e18 to show "0.5" to the user.
}
