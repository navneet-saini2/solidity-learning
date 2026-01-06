/**
 * @title Educational Multi-Signature Wallet
 * @author navneet-saini2
 * @notice ⚠️ EDUCATIONAL ONLY — NOT PRODUCTION READY
 *
 * This contract is intentionally written for LEARNING purposes to understand:
 * - How multi-signature wallets work (M-of-N approvals)
 * - Owner management and access control
 * - Transaction lifecycle: submit → confirm → revoke → execute
 * - Approval tracking using mappings
 * - Ether transfers using low-level call
 *
 * Design choices made for simplicity:
 * - Approval count is calculated by looping over owners
 * - Minimal modifiers (checks written inline)
 * - No gas optimizations for large owner sets
 *
 * ⚠️ Missing / intentionally simplified production features:
 * - Gas-optimized confirmation counting (O(1))
 * - Protection against gas-based DoS via large owner arrays
 * - Reentrancy guards
 * - Off-chain execution safety considerations
 * - Meta-transactions / EIP-712 signatures
 * - Owner management (add/remove owner)
 * - Timelocks or emergency pause
 *
 * ✅ Use this contract to:
 * - Read and understand MultiSig internals
 * - Practice auditing patterns
 * - Compare with production-grade implementations (e.g. Gnosis Safe)
 *
 * ❌ DO NOT deploy this contract with real funds.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MultiSig {
    /*//////////////////////////////////////////////////////////////
                                STATE
    //////////////////////////////////////////////////////////////*/

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
    }

    Transaction[] public transactions;

    // txId => owner => approved
    mapping(uint256 => mapping(address => bool)) public approved;

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error NotOwner();
    error InvalidOwner();
    error OwnerNotUnique();
    error InvalidRequired();
    error TxDoesNotExist();
    error TxAlreadyExecuted();
    error TxAlreadyApproved();
    error TxNotApproved();
    error NotEnoughApprovals();

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Submit(uint256 indexed txId, address indexed owner);
    event Confirm(uint256 indexed txId, address indexed owner);
    event Revoke(uint256 indexed txId, address indexed owner);
    event Execute(uint256 indexed txId);

    /*//////////////////////////////////////////////////////////////
                              MODIFIER
    //////////////////////////////////////////////////////////////*/

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address[] memory _owners, uint256 _required) {
        if (_owners.length == 0) revert InvalidOwner();
        if (_required == 0 || _required > _owners.length)
            revert InvalidRequired();

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            if (owner == address(0)) revert InvalidOwner();
            if (isOwner[owner]) revert OwnerNotUnique();

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    /*//////////////////////////////////////////////////////////////
                        RECEIVE ETHER
    //////////////////////////////////////////////////////////////*/

    receive() external payable {}

    /*//////////////////////////////////////////////////////////////
                        SUBMIT TRANSACTION
    //////////////////////////////////////////////////////////////*/

    function submitTransaction(address _to, uint256 _value) external onlyOwner {
        transactions.push(
            Transaction({to: _to, value: _value, executed: false})
        );

        emit Submit(transactions.length - 1, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                        CONFIRM TRANSACTION
    //////////////////////////////////////////////////////////////*/

    function confirmTransaction(uint256 txId) external onlyOwner {
        if (txId >= transactions.length) revert TxDoesNotExist();
        if (transactions[txId].executed) revert TxAlreadyExecuted();
        if (approved[txId][msg.sender]) revert TxAlreadyApproved();

        approved[txId][msg.sender] = true;

        emit Confirm(txId, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                        REVOKE CONFIRMATION
    //////////////////////////////////////////////////////////////*/

    function revokeConfirmation(uint256 txId) external onlyOwner {
        if (txId >= transactions.length) revert TxDoesNotExist();
        if (transactions[txId].executed) revert TxAlreadyExecuted();
        if (!approved[txId][msg.sender]) revert TxNotApproved();

        approved[txId][msg.sender] = false;

        emit Revoke(txId, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                        EXECUTE TRANSACTION
    //////////////////////////////////////////////////////////////*/

    function executeTransaction(uint256 txId) external onlyOwner {
        if (txId >= transactions.length) revert TxDoesNotExist();

        Transaction storage txn = transactions[txId];
        if (txn.executed) revert TxAlreadyExecuted();

        uint256 approvals = 0;

        for (uint256 i = 0; i < owners.length; i++) {
            if (approved[txId][owners[i]]) {
                approvals++;
            }
        }

        if (approvals < required) revert NotEnoughApprovals();

        txn.executed = true;

        (bool success, ) = txn.to.call{value: txn.value}("");
        require(success, "ETH_TRANSFER_FAILED");

        emit Execute(txId);
    }
}
