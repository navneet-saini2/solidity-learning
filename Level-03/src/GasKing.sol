//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract GasKing {
    // simple function
    /*
    function sumArray(uint256[] memory data) public pure returns (uint256) {
        uint256 total = 0;
        for (uint i = 0; i < data.length; i++) {
        total += data[i];
        }
        return total;
    }
    */

    // Gas optimize

    function sumArray(uint256[] memory data) public pure returns (uint256) {
        uint256 total = 0;
        uint256 len = data.length;
        for (uint256 i = 0; i < len; ) {
            total += data[i];
            unchecked {
                i++;
            }
        }
        return total;
    }
}
