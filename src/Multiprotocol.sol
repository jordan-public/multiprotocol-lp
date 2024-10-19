// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./types/TRouteStep.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IProtocol.sol";
import "./interfaces/IMultiprotocol.sol";

contract Multiprotocol is IMultiprotocol {
    IProtocol [] public protocols;

    constructor(IProtocol [] memory _protocols) {
        protocols = _protocols;
    }

    function execute(TRouteStep [] memory steps) external {
        require (steps.length > 1, "Multiprotocol: no steps"); // 0 - I/O, 1 - 1st step

        for (uint256 i = 0; i < steps.length; i++) {
            TRouteStep memory step = steps[i];
            require(step.fromProtocolIndex < protocols.length, "Multiprotocol: INVALID_INDEX");
            require(step.toProtocolIndex < protocols.length, "Multiprotocol: INVALID_INDEX");
            // Either of the two lines below can revert upon underflow as intended
            protocols[step.fromProtocolIndex].move(step.fromToken, -step.amount);
            protocols[step.toProtocolIndex].move(step.toToken, step.amount);

        }

        for (uint256 i = 0; i < protocols.length; i++) {
            protocols[i].happy();
        }
    }
}