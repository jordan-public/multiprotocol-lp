// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/IOracle.sol";

contract MockOracle is IOracle {
    function getPrice() external pure returns (uint256) {
        return 1000 * 10 ** 18;
    }
}