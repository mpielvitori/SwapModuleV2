// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Test, console } from "forge-std/Test.sol";
import { SwapModuleV2 } from "src/SwapModuleV2.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract BaseForkedTest is Test {
    SwapModuleV2 public sSwap;

    // Uniswap V2 Router (mainnet)
    address constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    // Sample tokens on mainnet (USDC, WETH)
    address constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    // NUEVO: Usamos la dirección estándar de WETH en Mainnet
    address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IERC20 public usdc = IERC20(USDC_ADDRESS);
    // NUEVO: Renombramos la variable a 'weth'
    IERC20 public weth = IERC20(WETH_ADDRESS);

    // Test actor
    address constant BARBA = address(0x77);

    // WETH tiene 18 decimales. 1e17 es 0.1 WETH.
    uint256 constant WETH_INITIAL_AMOUNT = 1e17; // 0.1 WETH (since WETH has 18 decimals)

    function setUp() public virtual {
        // create fork using env var ETH_RPC_URL
        string memory rpc = vm.envString("ETH_RPC_URL");
        vm.createSelectFork(rpc);

        // deploy contract
        sSwap = new SwapModuleV2(UNISWAP_V2_ROUTER);

        // Fond BARBA con WETH
        deal(WETH_ADDRESS, BARBA, WETH_INITIAL_AMOUNT);
        
        // OPCIONAL: También fundamos con ETH nativo, ya que es más natural para el usuario
        vm.deal(BARBA, WETH_INITIAL_AMOUNT); 

        console.log("Fork created with RPC:", rpc);
        console.log("SwapModuleV2 deployed:", address(sSwap));
        // NUEVO: Log del balance de WETH
        console.log("BARBA WETH balance:", weth.balanceOf(BARBA));
    }
}