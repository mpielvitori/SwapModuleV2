// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*  Representación del contrato Router de Uniswap V2, que permite a este
contrato llamar a sus funciones externas */
interface IUniswapV2Router02 {
    // Devuelve la dirección del token WETH (Wrapped Ether), esencial para manejar swaps que involucran a ETH
    function WETH() external pure returns (address);

    /* Ejecuta un swap donde conoces la cantidad exacta de token de entrada (amountIn) y especificas la cantidad mínima a recibir (amountOutMin)*/
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /* Ejecuta un swap donde la entrada es Ether nativo (usando payable) y se especifica la cantidad mínima a recibir (amountOutMin) */
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
}

contract SwapModuleV2 {
    //Aplica las funciones de seguridad de SafeERC20 a todas las instancias de IERC20
    using SafeERC20 for IERC20;

    // Dirección del Router de Uniswap V2 (ej. la dirección en Ethereum)
    IUniswapV2Router02 public immutable ROUTER;

    // evento que se emitirá después de cada swap exitoso
    event SwapExecuted(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    constructor(address _router) {
        require(_router != address(0), "router-zero");
        ROUTER = IUniswapV2Router02(_router);
    }

    /**
     * @notice Swap exact input ERC20 -> ERC20 using Uniswap V2
     * @param tokenIn token to send (must be approved by user)
     * @param tokenOut token to receive
     * @param amountIn exact amount of tokenIn
     * @param amountOutMin minimum acceptable amountOut (slippage protection)
     * @param deadline tx deadline (block.timestamp + N)
     */
    function swapExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline
    ) external {
        require(tokenIn != address(0) && tokenOut != address(0), "zero-token");
        require(amountIn > 0, "zero-amount");

        // Transfer tokenIn from sender to this contract
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        /*Nota: El usuario debe haber aprobado previamente este contrato para gastar
         sus tokens usando approve(address(SwapModuleV2), amountIn)*/

        /* The SwapModuleV2 contract authorizes the Uniswap Router
        to take tokens from its balance and execute the swap*/
        IERC20(tokenIn).safeIncreaseAllowance(address(ROUTER), amountIn);

        // Build simple path [tokenIn, tokenOut]
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // Execute swap
        uint256[] memory amounts = ROUTER.swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, deadline);

        emit SwapExecuted(msg.sender, tokenIn, tokenOut, amountIn, amounts[amounts.length - 1]);
    }

    /**
     * @notice Swap ETH -> ERC20 using Uniswap V2
     * @param tokenOut token to receive
     * @param amountOutMin minimum acceptable amountOut
     * @param deadline tx deadline
     */
    function swapExactEthForTokensSingle(address tokenOut, uint256 amountOutMin, uint256 deadline) external payable {
        require(tokenOut != address(0), "zero-token");
        require(msg.value > 0, "zero-eth");

        address weth = ROUTER.WETH();
        // path: WETH -> tokenOut
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = tokenOut;

        /* The ETH is sent to the Router, converted to WETH, exchanged for tokenOut,
        and the final token is sent directly back to the user (msg.sender)*/

        uint256[] memory amounts =
            ROUTER.swapExactETHForTokens{value: msg.value}(amountOutMin, path, msg.sender, deadline);

        emit SwapExecuted(msg.sender, weth, tokenOut, msg.value, amounts[amounts.length - 1]);
    }
}
