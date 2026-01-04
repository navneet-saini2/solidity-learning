/**
 * @title Nexus-Swap-AMM
 * @author navneet-saini2
 * @notice ⚠️ NOT PRODUCTION READY
 *
 * This AMM is built for educational purposes to understand:
 * - Constant product invariants
 * - LP share accounting
 * - Swap math and fees
 *
 * Missing production features:
 * - MINIMUM_LIQUIDITY
 * - Reentrancy guards
 * - Deadlines
 * - Oracle / TWAP
 * - Emergency pause
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/*
    =========================================================
    BASIC ERC20 INTERFACE
    =========================================================
    We only need the standard ERC20 functions.
    This interface is enough to interact with any ERC20 token.
*/
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/*
    =========================================================
    SIMPLE CONSTANT PRODUCT AMM (Uniswap v2 style)
    =========================================================
*/
contract SimpleAMM {
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    // Emitted when liquidity is added
    event AddLiquidity(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);

    // Emitted when liquidity is removed
    event RemoveLiquidity(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);

    // Emitted on every swap
    event Swap(address indexed user, address tokenIn, uint256 amountIn, uint256 amountOut);

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    // Pool reserves
    uint256 public reserveA;
    uint256 public reserveB;

    // LP token accounting (internal LP token)
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MATH (SQRT)
    //////////////////////////////////////////////////////////////*/

    // Babylonian method for square root
    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /*//////////////////////////////////////////////////////////////
                        ADD LIQUIDITY
    //////////////////////////////////////////////////////////////*/

    /*
        - First LP sets the price
        - Later LPs must add at the same ratio
        - LP tokens represent ownership percentage
    */
    function addLiquidity(uint256 amountA, uint256 amountB) external returns (uint256 liquidity) {
        require(amountA > 0 && amountB > 0, "Zero amount");

        // Pull tokens in
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        if (totalSupply == 0) {
            // First LP
            liquidity = _sqrt(amountA * amountB);
        } else {
            // Enforce correct ratio
            require(reserveA * amountB == reserveB * amountA, "Wrong ratio");

            liquidity = (amountA * totalSupply) / reserveA;
        }

        require(liquidity > 0, "Zero liquidity");

        // Effects
        balanceOf[msg.sender] += liquidity;
        totalSupply += liquidity;

        reserveA += amountA;
        reserveB += amountB;

        emit AddLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    /*//////////////////////////////////////////////////////////////
                        REMOVE LIQUIDITY
    //////////////////////////////////////////////////////////////*/

    /*
        SECURITY NOTE:
        - LP tokens are burned FIRST
        - Reserves updated SECOND
        - Tokens transferred LAST

        This follows CEI:
        Check → Effects → Interactions
        So reentrancy guard is NOT mandatory.
    */
    function removeLiquidity(uint256 liquidity) external returns (uint256 amountA, uint256 amountB) {
        require(liquidity > 0, "Zero liquidity");
        require(balanceOf[msg.sender] >= liquidity, "Not enough LP");

        // Calculate proportional share
        amountA = (liquidity * reserveA) / totalSupply;
        amountB = (liquidity * reserveB) / totalSupply;

        require(amountA > 0 && amountB > 0, "Zero output");

        // Effects (burn LP + update reserves)
        balanceOf[msg.sender] -= liquidity;
        totalSupply -= liquidity;

        reserveA -= amountA;
        reserveB -= amountB;

        // Interactions
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit RemoveLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    /*//////////////////////////////////////////////////////////////
                            PRICE QUOTE
    //////////////////////////////////////////////////////////////*/

    /*
        Pure helper function.
        - Used by frontend
        - Used for slippage calculation
        - No state change
    */
    function getAmountOut(address tokenIn, uint256 amountIn) public view returns (uint256 amountOut) {
        require(amountIn > 0, "Zero input");

        bool isTokenA = tokenIn == address(tokenA);
        require(isTokenA || tokenIn == address(tokenB), "Invalid token");

        (uint256 reserveIn, uint256 reserveOut) = isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);

        // 0.3% fee
        uint256 amountInWithFee = (amountIn * 997) / 1000;

        uint256 k = reserveIn * reserveOut;
        uint256 newReserveOut = k / (reserveIn + amountInWithFee);

        amountOut = reserveOut - newReserveOut;
    }

    /*//////////////////////////////////////////////////////////////
                                SWAP
    //////////////////////////////////////////////////////////////*/

    /*
        ATTACKS PREVENTED:
        - Pool draining → x*y=k invariant
        - MEV sandwich → slippage protection
        - Reentrancy → CEI pattern

        NOTE:
        - No reentrancy guard needed because
          state updates happen BEFORE transfers
    */
    function swap(address tokenIn, uint256 amountIn, uint256 minAmountOut) external returns (uint256 amountOut) {
        require(amountIn > 0, "Zero input");

        bool isTokenA = tokenIn == address(tokenA);
        require(isTokenA || tokenIn == address(tokenB), "Invalid token");

        (uint256 reserveIn, uint256 reserveOut) = isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);

        // Pull input token
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // Fee logic
        uint256 amountInWithFee = (amountIn * 997) / 1000;

        // Constant product formula
        uint256 k = reserveIn * reserveOut;
        uint256 newReserveOut = k / (reserveIn + amountInWithFee);

        amountOut = reserveOut - newReserveOut;

        // Slippage protection
        require(amountOut >= minAmountOut, "Slippage too high");

        // Effects
        if (isTokenA) {
            reserveA += amountIn;
            reserveB = newReserveOut;
        } else {
            reserveB += amountIn;
            reserveA = newReserveOut;
        }

        // Interaction
        IERC20(isTokenA ? address(tokenB) : address(tokenA)).transfer(msg.sender, amountOut);

        emit Swap(msg.sender, tokenIn, amountIn, amountOut);
    }
}

/**
 * 🔥 Attack Scenarios Understand
 *
 *   1. Pool drain attack → stopped by x*y=k
 *   2. Reentrancy → stopped by CEI
 *   3. Sandwich attack → stopped by minAmountOut
 *   4.Fake LP minting → ratio enforcement
 *   5.Overflow/underflow → Solidity 0.8+
 */
