#!/bin/zsh

nargo compile
~/.bb/bb write_vk -b ./target/constantsum.json
~/.bb/bb contract
cp target/contract.sol ../src/constantsum.sol