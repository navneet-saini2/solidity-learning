// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.30;

interface IPriceFeed {
    function getLatestPrice() external view returns (uint256);
}

contract PriceConsumer {
    IPriceFeed public priceFeed;

    constructor(address _priceFeedAddress) {
        priceFeed = IPriceFeed(_priceFeedAddress);
    }

    function getThePrice() public view returns (uint256) {
        return priceFeed.getLatestPrice();
    }
}
