//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract GasSqueezer {
    // --- UNOPTIMIZED (Uses 4 slots/shelves) ---
    // uint256 a = 1;
    // uint256 b = 15;
    // ...

    // --- OPTIMIZED (Uses 1 slot/shelf) ---
    // Because 64 + 64 + 64 + 64 = 256 bits (Exactly 1 slot)
    uint64 public firstNo = 1;
    uint64 public secondNo = 15;
    uint64 public thirdNo = 20;
    uint64 public fourthNo = 200;

    // --- IMMUTABLE ---
    // Immutable (Saved in bytecode, not storage)
    // Why is this cheap? Because it's not stored on a "shelf"!
    // It is hardcoded directly into the contract's bytecode.

    address public immutable VAULT_ADDRESS;

    constructor(address _vault) {
        VAULT_ADDRESS = _vault;
    }

    // Calldata (No copying, saves gas)
    function readNames(
        string[] calldata _names
    ) public pure returns (string memory) {
        return _names[0];
    }
}
