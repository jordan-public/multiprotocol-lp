// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

// This prototype only implements steps with 1 input and 1 output
struct TRouteStep {
    uint256 fromProtocolIndex; // protocol index - which protocol in the array
    uint256 toProtocolIndex; // protocol index - which protocol in the array
    uint256 fromToken; // 0 for outside, token index - which token in the protocol
    uint256 toToken; // 0 for outside, token index - which token in the protocol
    int256 amount; // amount to transfer, negative for input, positive for output
}