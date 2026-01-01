//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract SimpleAMM {
    // state variables
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    // constructor
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    // addLiquidity
    function addLiquidity(uint256 amount0, uint256 amount1) external returns (uint256 liquidity) {}

    // swap
    // removeLiquidity
}
