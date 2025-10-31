// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
 
contract Wrapper {
    using SafeERC20 for IERC20;

    error ZeroAddress();
    error ZeroAmount();

    IUniswapV2Router02 public immutable ROUTER;
    address public immutable USDC;
    address public immutable WETH;

    constructor(address _router, address _usdc) {
        if (_router == address(0) || _usdc == address(0)) revert ZeroAddress();
        ROUTER = IUniswapV2Router02(_router);
        USDC = _usdc;
        WETH = ROUTER.WETH();
    }

    function swapToUsdc(address tokenIn, uint256 amountIn, uint256 amountOutMin, address recipient)
        external
        returns (uint256 amountOut)
    {
        if (tokenIn == address(0) || recipient == address(0)) revert ZeroAddress();
        if (amountIn == 0) revert ZeroAmount();

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        if (tokenIn == USDC) {
            IERC20(USDC).safeTransfer(recipient, amountIn);
            return amountIn;
        }

        // ensure allowance for router
        if (IERC20(tokenIn).allowance(address(this), address(ROUTER)) < amountIn) {
            //IERC20(tokenIn).safeApprove(address(router), 0);
            IERC20(tokenIn).safeIncreaseAllowance(address(ROUTER), type(uint256).max);
        }

        address[] memory path;
        if (tokenIn == WETH) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = USDC;
        } else {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = WETH;
            path[2] = USDC;
        }

        uint256[] memory amounts = ROUTER.swapExactTokensForTokens(amountIn, amountOutMin, path, recipient, block.timestamp);

        amountOut = amounts[amounts.length - 1];
    }

    function previewSwapToUsdc(address tokenIn, uint256 amountIn) external view returns (uint256 amountOut) {
        if (tokenIn == address(0)) revert ZeroAddress();
        if (amountIn == 0) revert ZeroAmount();

        if (tokenIn == USDC) {
            return amountIn;
        }

        address[] memory path;
        if (tokenIn == WETH) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = USDC;
        } else {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = WETH;
            path[2] = USDC;
        }

        uint256[] memory amounts = ROUTER.getAmountsOut(amountIn, path);
        amountOut = amounts[amounts.length - 1];
    }
}

