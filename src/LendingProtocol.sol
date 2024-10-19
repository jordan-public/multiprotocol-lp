// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./types/TPool.sol";
import "./interfaces/IProtocol.sol";
import "./interfaces/IMultiprotocol.sol";
import "./interfaces/IOracle.sol";
import "./MockOracle.sol";

// Todo: Implement loan liquidations!!!
contract LendingProtocol is IProtocol {
    TPool pool;
    IMultiprotocol multiprotocol;
    IOracle oracle;

    uint256 MIN_COLLATERAL_RATIO = 15 * 10 ** 17;

    struct TLoan {
        uint256 collateral;
        uint256 loan;
    }   
    mapping (address => TLoan) loans; // borrower -> TLoan

    constructor (TPool memory _pool) {
        pool = _pool;
        pool.protocol = IProtocol(address(this));
        require(pool.tokens.length == 2, "LendingProtocol: INVALID_LENGTH");
        require(2 == pool.amounts.length, "LendingProtocol: INVALID_LENGTH");
        require(2 == pool.newAmounts.length, "LendingProtocol: INVALID_LENGTH");
        oracle = new MockOracle();
    }

    function setParent() external {
        multiprotocol = IMultiprotocol(msg.sender);
    }

    function token(uint256 index) external view override returns (address) {
        require(index < 2, "LendingProtocol: INVALID_INDEX");
        return pool.tokens[index];
    }

    function move(address, uint256 tokenIndex, int256 amount) external  {
        if (amount >= 0)
            pool.newAmounts[tokenIndex] = pool.amounts[tokenIndex] + uint256(amount);
        else
            pool.newAmounts[tokenIndex] = pool.amounts[tokenIndex] - uint256(-amount); // Can revert upon underflow as intended
    }

    function happy(bytes calldata) external override {
        loans[tx.origin].collateral += pool.newAmounts[0];
        loans[tx.origin].loan += pool.newAmounts[1];
        require(loans[tx.origin].collateral >= loans[tx.origin].loan * oracle.getPrice() * 10 ** 18 / 10 * 6 * MIN_COLLATERAL_RATIO / 10 ** 18, "LendingPool: UNDERCOLLATERALIZED");
        pool.amounts[0] = pool.newAmounts[0];
        pool.amounts[1] = pool.newAmounts[1];
    }

    // Issuing LP tokens is not yet supported (irrelevant for the purpose of this prototype)
    function deposit(uint256 [] memory amounts) external override {
        // Todo: Make sure the caller is the IMultiprotocol!!!
        require(2 == amounts.length, "LendingProtocol: INVALID_LENGTH");
        pool.amounts[0] += amounts[0];
        pool.amounts[1] += amounts[1];
        multiprotocol.transferIn(msg.sender, pool.tokens[0], amounts[0]);
        multiprotocol.transferIn(msg.sender, pool.tokens[1], amounts[1]);
    }

    // Burning LP tokens is not yet supported (irrelevant for the purpose of this prototype)
    function withdraw(uint256 [] memory amounts) external override {
        // Todo: Make sure the caller is the IMultiprotocol!!!
        require(2 == amounts.length, "LendingProtocol: INVALID_LENGTH");
        pool.amounts[0] -= amounts[0];
        pool.amounts[1] -= amounts[1];
        multiprotocol.transferOut(msg.sender, pool.tokens[0], amounts[0]);
        multiprotocol.transferOut(msg.sender, pool.tokens[1], amounts[1]);
    }
}