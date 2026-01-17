# Smart Contract Testing Notes (Foundry)

## 1. Why testing matters
- Prevents critical bugs
- Protects user funds
- Required for audits & jobs

---

## 2. Test Structure (Mental Model) 
  A test is just:

- 1. Set up state
- 2. Do something
- 3. Check what happened

SETUP → ACTION → ASSERT

---

## 3. Types of Tests

### 3.1 Unit Tests
- Test a single function
- Example: addLiquidity updates reserves

### 3.2 Integration Tests
- Test multiple functions together
- Example: addLiquidity → swap

### 3.3 Revert Tests
- Ensure contract fails safely
- Use vm.expectRevert()

### 3.4 Fuzz Tests
- Randomized inputs
- Use vm.assume()

### 3.5 Invariant Tests
- Rules that must always hold
- Example: reserves never negative

---

## 4. Common Foundry Helpers
- vm.prank()
- vm.expectRevert()
- vm.assume()
- vm.warp()
- vm.roll()

---

## 5. Personal Notes
- Always test access control
- Every public function must have revert tests
- Prefer fuzzing for math-heavy logic

---

# Explain in details :

## Smart Contract Testing – 1 Page Cheat Sheet (Foundry)

## Mental Model
A test is always:
SETUP → ACTION → ASSERT

If the assertion fails → the test fails.

---

## Basic Test Anatomy

```solidity
import "forge-std/Test.sol";
```
Gives access to:

- assertEq
- assertTrue
- vm.prank
- vm.expectRevert
- fuzz helpers

```solidity
contract MyTest is Test {}
```   
Test-only contract
Runs in Foundry VM
Not production code

## setUp() – Test Reset

```solidity
function setUp() public {
    contractInstance = new Contract();
}
```
- Runs before every test
- Fresh deployment each time
- No shared state

Rule: Every test starts from zero.

## Simple Test Example
```solidity
function testAddLiquidity() public {
    dex.addLiquidity(100, 200);        // ACTION
    assertEq(dex.reserveA(), 100);     // ASSERT
    assertEq(dex.reserveB(), 200);     // ASSERT
}
```
- Call function
- Check state
- If any assert fails → test fails

#### Assertions
```solidity
assertEq(actual, expected);
```
Fails if values differ.
```solidity
assertTrue(condition);
```
Fails if condition is false.
Tests must fail loudly.

## Revert Tests (Security Critical)
```solidity
function testRevertOnInvalidInput() public {
    vm.expectRevert("Invalid amounts");
    dex.addLiquidity(0, 100);
}
```
- Tells Foundry the next call must revert
- No revert → test fails

### vm.prank() – Fake msg.sender
```solidity
vm.prank(attacker);
contract.call();
```
- Next call uses msg.sender = attacker
- Used for:
  - Access control
  - Multisig
  - Permission checks

## Fuzz Tests (Bug Hunting)
```solidity
function testFuzz(uint256 a, uint256 b) public {
    vm.assume(a > 0 && b > 0);
    dex.addLiquidity(a, b);
    assertEq(dex.reserveA(), a);
}
```
- Foundry supplies random inputs
- Runs hundreds of times
- vm.assume() filters bad values

Mental model: Foundry attacks your contract.

## Invariant Tests (Always True Rules)
```solidity
function invariantReservesPositive() public {
    assertTrue(dex.reserveA() >= 0);
}
```
- Foundry calls functions randomly
- Invariant checked after each call
- If ever false → test fails

Rule: Must hold no matter what.

## Common VM Helpers

| Helper | Meaning |
|-------|---------|
| `vm.prank(x)` | `msg.sender = x` |
| `vm.expectRevert()` | Next call must fail |
| `vm.assume()` | Filter fuzz inputs |
| `vm.warp(t)` | Change `block.timestamp` |
| `vm.roll(n)` | Change `block.number` |


### Golden Rules
- Every public function needs tests
- Always test failure cases
- Use fuzz tests for math logic
- Keep tests clean, notes in .md
- This is professional-level testing.
