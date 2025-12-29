//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IERC20 {
    // functions later
}

contract SimpleAMM {
    // state variables
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    // constructor
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    // addLiquidity
    // swap
    // removeLiquidity
}
