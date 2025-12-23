// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

// 1. We need to know what function we are calling
interface IPriceFeed {
    function getPrice() external view returns (uint256);
}

contract ExternalCaller {
    function safeGetPrice(
        address _priceFeedAddress
    ) public view returns (uint256) {
        IPriceFeed feed = IPriceFeed(_priceFeedAddress);

        // 2. The TRY block
        try feed.getPrice() returns (uint256 price) {
            return price; // If it works, return the real price
        } catch // 3. The CATCH block
        {
            return 0; // If the other contract fails, return 0 instead of crashing
        }
    }
}
