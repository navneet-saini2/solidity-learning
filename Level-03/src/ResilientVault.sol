//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

interface IVault {
    function totalAssets() external view returns (uint256);
}

contract ResilientVault {
    function checkOtherVault(address _target) public view returns (uint256) {
        try IVault(_target).totalAssets() returns (uint256 number) {
            return number;
        } catch {
            return 999;
        }
    }
}
