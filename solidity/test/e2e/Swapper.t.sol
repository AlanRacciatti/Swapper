// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {CommonE2EBase} from 'test/e2e/Common.sol';

contract E2EGreeter is CommonE2EBase {
    function test_Helper_Tokens() public {
        vm.deal(user, 4 ether);

        assertEq(INITIAL_SUPPLY * 10 ** blues.decimals(), blues.balanceOf(owner));
        assertEq(INITIAL_SUPPLY * 10 ** pop.decimals(), pop.balanceOf(owner));

        vm.startPrank(user);

        assertEq(blues.balanceOf(user), 0);
        assertEq(pop.balanceOf(user), 0);

        blues.mint{value: 1 ether}(1);
        pop.mint{value: 1 ether}(1);

        assertEq(blues.balanceOf(user), 1);
        assertEq(pop.balanceOf(user), 1);

        vm.expectRevert();
        blues.mint(1);

        vm.expectRevert();
        blues.mint{value: 2 ether}(1);

        vm.expectRevert();
        pop.mint(1);

        vm.expectRevert();
        pop.mint{value: 2 ether}(1);

        vm.stopPrank();
    }

    /// @notice Example Call Sequence
    function test_Swapper() public {
        // 1. Deploy all tokens done in Common.sol
        // 2. Deploy swapping done in Common.sol

        vm.deal(user, 200 ether);

        vm.startPrank(user);
        blues.mint{value: 200 ether}(200);

        blues.approve(address(swapper), 200); // 100 more than needed for next swap
        swapper.swap(address(blues), 100); // 3. Swap tokens

        assertEq(swapper.balanceOf(user), 100 * 10 ** 18);

        vm.stopPrank();

        vm.prank(owner);
        swapper.setPrice(2); // 4. Set price

        vm.prank(user);
        swapper.swap(address(blues), 100);

        assertEq(swapper.balanceOf(user), 150 * 10 ** 18);
    }
}
