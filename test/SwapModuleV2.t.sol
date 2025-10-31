// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {BaseForkedTest} from "./BaseForkedTest.t.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

contract SwapModuleV2Test is BaseForkedTest {
    // NUEVA PRUEBA: WETH -> USDC
    function test_swap_weth_to_usdc() public {
        // parámetros del swap
        // Ajustamos amountIn a la constante WETH_INITIAL_AMOUNT (0.1 WETH)
        uint256 amountIn = WETH_INITIAL_AMOUNT;
        uint256 minOut = 1;
        uint256 deadline = block.timestamp + 600;

        // Simular acciones desde BARBA
        vm.startPrank(BARBA);

        // Antes: aprobar SwapModule para transferir WETH desde BARBA
        IERC20(WETH_ADDRESS).approve(address(sSwap), amountIn);

        uint256 usdcBefore = usdc.balanceOf(BARBA);

        // Llamada al SwapModule: WETH -> USDC
        sSwap.swapExactInputSingle(WETH_ADDRESS, USDC_ADDRESS, amountIn, minOut, deadline);

        uint256 usdcAfter = usdc.balanceOf(BARBA);
        vm.stopPrank();

        console.log("WETH In:", amountIn);
        console.log("USDC antes:", usdcBefore);
        console.log("USDC despues:", usdcAfter);

        assertGt(usdcAfter, usdcBefore, "No se recibieron USDC tras el swap WETH->USDC");
    }
}
