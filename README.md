# multiprotocol-lp
Multiprotocol Liquidity Pools

## Demo

The demo video and description can be found [here](./demo/README.md).

## Abstract

Inspired by Uniswap V4, which hosts multiple Liquidity Pools in a single contracts, I expanded the concept to host various multiple protocols in a single pool. This minimizes the asset transfers calls even further without sacrificing safety. Through common accounting restrictions, additional safety is achieved, as well as additional safety of the protocols. Using these accounting restriction we show a great simplification of concentrated liquidity  implementation, lending, and even implementation of demanding restrictions that can be calculated off-chain and entered as ZK / validity proofs that are succinctly verified on-chain.

## Implementation

The implementation is running on multiple EVMs and it is written in Solidity. The sample ZK component’s prover is written in Aztec Noir. The Smart Contract that represents the multi-protocol LP is generic, and various protocols can be added as long as they implement our specific interface for creation, deposit/withdrawal and transactions. I also implemented the sample concentrated liquidity swap pool, lending pool and constant-sum ZK swap pool. The latter is the simplest example of ZK pool, but in reality, more complicated protocols can be implemented in this manner in order to save on gas by calculating the constraints off-chain.
