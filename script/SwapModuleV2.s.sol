// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SwapModuleV2} from "../src/SwapModuleV2.sol";

contract SwapModuleV2Script is Script {
    SwapModuleV2 public swapModuleV2;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Uniswap V2 Router
        address uniswapV2Router = vm.parseAddress(vm.envString("UNISWAP_V2_ROUTER"));

        swapModuleV2 = new SwapModuleV2(uniswapV2Router);

        vm.stopBroadcast();
    }
}
