// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../types/TRouteStep.sol";
import "../interfaces/IProtocol.sol";

interface IMultiprotocol {
    function protocols(uint256 index) external view returns (IProtocol);
    function execute(TRouteStep [] memory steps) external;
}