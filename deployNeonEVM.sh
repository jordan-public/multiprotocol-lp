#!/bin/zsh

# Run anvil.sh in another shell before running this

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/Multiprotocol.s.sol:Deploy  --skip-simulation --legacy --rpc-url "https://devnet.neonevm.org" --sender $SENDER --private-key $PRIVATE_KEY --broadcast -vvvv