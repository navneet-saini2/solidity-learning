//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract SecretReward {
    mapping(address => bytes32) public commits;

    function commit(bytes32 _hash) public {
        //_hash = keccak256(abi.encodePacked(_password, msg.sender));
        commits[msg.sender] = _hash;
    }

    function reveal(string memory _password) public view returns (bool) {
        bytes32 calculatedHash = keccak256(
            abi.encodePacked(_password, msg.sender)
        );
        if (commits[msg.sender] == calculatedHash) {
            return true;
        } else {
            return false;
        }
    }
}
