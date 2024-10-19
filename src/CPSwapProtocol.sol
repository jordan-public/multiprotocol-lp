// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./types/TPool.sol";
import "./interfaces/IProtocol.sol";

contract CPSwapProtocol is IProtocol {
    TPool pool;
    uint256 [] public virtualAmounts;

    constructor (TPool memory _pool, uint256 [] memory _virtualAmounts) {
        pool = _pool;
        pool.protocol = IProtocol(address(this));
        require(pool.tokens.length == 2, "CPSwapProtocol: INVALID_LENGTH");
        require(2 == pool.amounts.length, "CPSwapProtocol: INVALID_LENGTH");
        require(2 == pool.newAmounts.length, "CPSwapProtocol: INVALID_LENGTH");
        require(2 == virtualAmounts.length, "CPSwapProtocol: INVALID_LENGTH");
        virtualAmounts[0] = _virtualAmounts[0];
        virtualAmounts[1] = _virtualAmounts[1];
    }

    function token(uint256 index) external view override returns (address) {
        require(index < 2, "CPSwapProtocol: INVALID_INDEX");
        return pool.tokens[index];
    }

    function move(uint256 tokenIndex, int256 amount) external  {
        if (amount >= 0)
            pool.newAmounts[tokenIndex] += uint256(amount);
        else
            pool.newAmounts[tokenIndex] -= uint256(-amount); // Can revert upon underflow as intended
    }

    function happy() external override {
        uint256 oldProduct = virtualAmounts[0] * virtualAmounts[1];
        virtualAmounts[0] += pool.newAmounts[0];
        virtualAmounts[1] += pool.newAmounts[1];
        virtualAmounts[0] -= pool.amounts[0];
        virtualAmounts[1] -= pool.amounts[1];
        require(oldProduct <= virtualAmounts[0] * virtualAmounts[1], "CPSwapProtocol: CONSTANT_PRODUCT");
        pool.amounts[0] = pool.newAmounts[0];
        pool.amounts[1] = pool.newAmounts[1];
    }

    // Issuing LP tokens is not yet supported (irrelevant for the purpose of this prototype)
    function deposit(uint256 [] memory amounts) external override {
        require(2 == amounts.length, "CPSwapProtocol: INVALID_LENGTH");
        pool.amounts[0] += amounts[0];
        pool.amounts[1] += amounts[1];
        virtualAmounts[0] += amounts[0];
        virtualAmounts[1] += amounts[1];
    }

    // Burning LP tokens is not yet supported (irrelevant for the purpose of this prototype)
    function withdraw(uint256 [] memory amounts) external override {
        require(2 == amounts.length, "CPSwapProtocol: INVALID_LENGTH");
        pool.amounts[0] -= amounts[0];
        pool.amounts[1] -= amounts[1];
        virtualAmounts[0] -= amounts[0];
        virtualAmounts[1] -= amounts[1];
    }
}