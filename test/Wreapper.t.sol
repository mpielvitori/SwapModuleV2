// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//import {Test} from "forge-std/Test.sol";
import "forge-std/Test.sol";
import {Wrapper} from "../src/Wrapper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WrapperTest is Test {
    Wrapper public wrapper;
    address constant ROUTER = 0x2ca7d64A7EFE2D62A725E2B35Cf7230D6677FfEe;
    address constant USDC = 0xfC9201f4116aE6b054722E10b98D904829b469c3;
    address constant WETH = 0x5AEa5775959fBC2557Cc8789bC1bf90A239D9a91;
    address constant WHALE = 0x6a956f0AEd3b8625F20d696A5e934A5DE8C27A2C;
    address constant USER = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    function setUp() public {
        vm.createSelectFork(vm.envString("ZETACHAIN_RPC_URL"));
        wrapper = new Wrapper(ROUTER,USDC);
    }

    function testSwapUSDCtoUSDC() public {
        vm.startPrank(WHALE);
        uint256 amountIn = 1_000_000; // 1 USDC (6 decimals)
        uint256 before = IERC20(USDC).balanceOf(USER);

        console.log("Balance before swap:", before);

        IERC20(USDC).approve(address(wrapper), type(uint256).max);
        wrapper.swapToUsdc(USDC, amountIn, 0, USER);

        uint256 afterBal = IERC20(USDC).balanceOf(USER);

        console.log("Balance after swap:", afterBal);

        assertGt(afterBal, before, "swap failed");
        vm.stopPrank();
    }

    /*
        assertEq(a,b,"failed porque...")
        assertGt
        assertGe
        assertLt
        assertLe
        assertTrue, assertFalse

        assertApproxEqAbs, assertApproxEqRel(a,b, tolerancia)
    */
    function testSwapUSDCtoUSDCMustRevert() public {
        vm.startPrank(WHALE);
        uint256 amountIn = 1_000_000; // 1 USDC (6 decimals)
        uint256 before = IERC20(USDC).balanceOf(USER);

        console.log("Balance before swap:", before);
        
        vm.expectRevert();

        //IERC20(USDC).approve(address(wrapper), type(uint256).max);
        wrapper.swapToUsdc(USDC, amountIn, 0, USER);

        
        uint256 afterBal = IERC20(USDC).balanceOf(USER);

        console.log("Balance after swap:", afterBal);

        //assertGt(afterBal, before, "swap failed");
        vm.stopPrank();
    }

}