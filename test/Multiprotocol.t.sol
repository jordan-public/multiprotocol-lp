// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../src/types/TPool.sol";
import "../src/types/TRouteStep.sol";
import "../src/interfaces/IProtocol.sol";
import "../src/interfaces/IMultiprotocol.sol";
import "../src/MockERC20.sol";
import "../src/IOProtocol.sol";
import "../src/CPSwapProtocol.sol";
import "../src/Multiprotocol.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {Test, console} from "forge-std/Test.sol";

contract MultiprotocolTest is Test {
    IERC20Metadata public USDC;
    IERC20Metadata public WETH;

    IMultiprotocol public mp;

    function setUp() public {
        USDC = IERC20Metadata(address(new MockERC20("Test USDC", "USDC", 6, 10 ** 6 * 10 ** 6))); // 1M total supply
        WETH = IERC20Metadata(address(new MockERC20("Test WETH", "WETH", 18, 10 ** 3 * 10 ** 18))); // 1K total supply
        
        TPool memory ioPool;
        ioPool.tokens = new address[](2);
        ioPool.amounts = new uint256[](2);
        ioPool.newAmounts = new uint256[](2);
        ioPool.tokens[0] = address(USDC);
        ioPool.tokens[1] = address(WETH);

        TPool memory cpPool;
        cpPool.tokens = new address[](2);
        cpPool.amounts = new uint256[](2);
        cpPool.newAmounts = new uint256[](2);
        cpPool.tokens[0] = address(USDC);
        cpPool.tokens[1] = address(WETH);

        // Creaate protocols
        IProtocol [] memory protocols = new IProtocol[](2);
        protocols[0] = new IOProtocol(ioPool);
        uint256 [] memory va = new uint256[](2);
        va[0] = 10000 * 10 ** 6; // 10000 USDC
        va[1] = 10 * 10 ** 18; // 10 WETH
        protocols[1] = new CPSwapProtocol(cpPool, va);
        uint256 [] memory ra = new uint256[](2);
        ra[0] = 1000 * 10 ** 6; // 1000 USDC
        ra[1] = 1 * 10 ** 18; // 1 WETH

        mp = new Multiprotocol(protocols);
        USDC.approve(address(mp), ra[0]);
        WETH.approve(address(mp), ra[1]);
        protocols[1].deposit(ra);
    }

    function test_DepositAndSwap() public {
        USDC.approve(address(mp), 1000 * 10 ** 6); // Authorize IOProtocol to spend 1000 USDC
        // Create a route
        TRouteStep [] memory steps = new TRouteStep[](2);
        steps[0].fromProtocolIndex = 0;
        steps[0].fromToken = 0;
        steps[0].toProtocolIndex = 1;
        steps[0].toToken = 0;
        steps[0].amount = 1000 * 10 ** 6; // 1000 USDC
        steps[1].fromProtocolIndex = 1;
        steps[1].fromToken = 1;
        steps[1].toProtocolIndex = 0;
        steps[1].toToken = 1;
        steps[1].amount = 9 * 10 ** 17; //  WETH
        mp.execute(steps);
    }

    function test_DepositAndSwapCPFail() public {
        USDC.approve(address(mp), 1000 * 10 ** 6); // Authorize IOProtocol to spend 1000 USDC
        // Create a route
        TRouteStep [] memory steps = new TRouteStep[](2);
        steps[0].fromProtocolIndex = 0;
        steps[0].fromToken = 0;
        steps[0].toProtocolIndex = 1;
        steps[0].toToken = 0;
        steps[0].amount = 1000 * 10 ** 6; // 1000 USDC
        steps[1].fromProtocolIndex = 1;
        steps[1].fromToken = 1;
        steps[1].toProtocolIndex = 0;
        steps[1].toToken = 1;
        steps[1].amount = 1 * 10 ** 18; //  WETH
        // Should fail because CP protocol does not have enough WETH
        vm.expectRevert();
            mp.execute(steps);
    }

    function test_DepositAndTrySwapBeyondLRange() public {
        USDC.approve(address(mp), 2000 * 10 ** 6); // Authorize IOProtocol to spend 1000 USDC
        // Create a route
        TRouteStep [] memory steps = new TRouteStep[](2);
        steps[0].fromProtocolIndex = 0;
        steps[0].fromToken = 0;
        steps[0].toProtocolIndex = 1;
        steps[0].toToken = 0;
        steps[0].amount = 2000 * 10 ** 6; // 1000 USDC
        steps[1].fromProtocolIndex = 1;
        steps[1].fromToken = 1;
        steps[1].toProtocolIndex = 0;
        steps[1].toToken = 1;
        steps[1].amount = 19 * 10 ** 17; //  WETH
        vm.expectRevert();
            mp.execute(steps);
    }

}
