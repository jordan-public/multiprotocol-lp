// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface IOracle {
    function getPrice() external view returns (uint256);
}