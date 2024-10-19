// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../interfaces/IProtocol.sol";

struct TPool {
    address [] tokens;
    uint256 [] amounts;
    uint256 [] newAmounts;
    IProtocol protocol;
}