// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./types/TPool.sol";
import "./interfaces/IProtocol.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMultiprotocol.sol";

// Input / Output Protocol used for transferring assets into and out of the Multiprotocol for execution
contract IOProtocol is IProtocol {
    TPool pool;
    IMultiprotocol multiprotocol;

    constructor (TPool memory _pool) {
        pool = _pool;
        pool.protocol = IProtocol(address(this));
        require(pool.tokens.length >= 2, "IOProtocol: INVALID_LENGTH");
        require(pool.tokens.length == pool.amounts.length, "IOProtocol: INVALID_LENGTH");
        require(pool.tokens.length == pool.newAmounts.length, "IOProtocol: INVALID_LENGTH");
    }

    function setParent() external {
        multiprotocol = IMultiprotocol(msg.sender);
    }

    function token(uint256 index) external view returns (address) {
        require(index < pool.tokens.length, "IOProtocol: INVALID_INDEX");
        return pool.tokens[index];
    }

    function move(address user, uint256 tokenIndex, int256 amount) external  {
        if (amount < 0) { // Input
            //pool.newAmounts[tokenIndex] = pool.amounts[tokenIndex] + uint256(-amount);
            multiprotocol.transferIn(user, pool.tokens[tokenIndex], uint256(-amount));
        } else if (amount > 0) { // Output
            //pool.newAmounts[tokenIndex] = pool.amounts[tokenIndex] - uint256(amount); // Can revert upon underflow as intended
            multiprotocol.transferOut(user, pool.tokens[tokenIndex], uint256(amount));
        }
    }

    function happy(bytes calldata) external view {
        // Comment below for donation into the Multiprotocol to be potentially used in the next call atomically
        // for (uint256 i = 0; i < pool.tokens.length; i++) {
        //     pool.newAmounts[i] == 0; // Consumed
        // }
    }

    // Issuing LP tokens is not yet supported (irrelevant for the purpose of this prototype)
    function deposit(uint256 [] memory) external pure {
        revert("IOProtocol: NOT_SUPPORTED");
    }

    // Burning LP tokens is not yet supported (irrelevant for the purpose of this prototype)
    function withdraw(uint256 [] memory) external pure {
        revert("IOProtocol: NOT_SUPPORTED");
    }
}