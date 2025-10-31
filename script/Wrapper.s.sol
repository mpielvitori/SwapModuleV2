// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Wrapper} from "../src/Wrapper.sol";

contract WrapperScript is Script {
    Wrapper public wrapper;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Uniswap V2 Router
        address uniswapV2Router = vm.parseAddress(vm.envString("UNISWAP_V2_ROUTER"));
        address usdcAddress = vm.parseAddress(vm.envString("USDC_ADDRESS"));

        wrapper = new Wrapper(uniswapV2Router, usdcAddress);

        vm.stopBroadcast();
    }
}