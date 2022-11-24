// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <0.9.0;

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';
import {DSTestFull} from 'test/utils/DSTestFull.sol';
import {Blues, Pop} from 'contracts/HelperTokens.sol';
import {Swapper} from 'contracts/Swapper.sol';

abstract contract Base is DSTestFull {
    address user = label('user');
    Blues blues;
    Pop pop;
    Swapper swapper;
}

contract Unit_Swapper_Constructor is Base {
    function test_TokenPrice(uint256 _tokenPrice) public {
        blues = new Blues(1 ether, 10000);
        pop = new Pop(1 ether, 10000);
        swapper = new Swapper(_tokenPrice, [address(blues), address(pop)]);

        assertEq(swapper.tokenPrice(), _tokenPrice);
    }
}

contract Unit_Swapper_Swap is Base {
    function test_TokenSwap(uint128 _amount) public {
        vm.assume(_amount > 0); // Amount must be > 0

        blues = new Blues(1, 10000);
        pop = new Pop(1, 10000);
        swapper = new Swapper(100, [address(blues), address(pop)]);

        vm.deal(user, 1 * _amount);
        vm.startPrank(user);

        blues.mint{value: (blues.TOKEN_PRICE() * _amount)}(_amount);
        blues.approve(address(swapper), _amount);
        swapper.swap(address(blues), _amount);

        assertEq(blues.balanceOf(user), 0);
        assertEq(swapper.balanceOf(user), (_amount / swapper.tokenPrice()) * 10 ** 18);

        vm.stopPrank();
    }

    function test_AmountZero() public {
        blues = new Blues(1, 10000);
        pop = new Pop(1, 10000);
        swapper = new Swapper(100, [address(blues), address(pop)]);

        vm.expectRevert();
        swapper.swap(address(blues), 0);
    }

    function test_WrongAddress(uint128 _amount) public {
        vm.assume(_amount > 0);

        blues = new Blues(1, 10000);
        pop = new Pop(1, 10000);
        swapper = new Swapper(100, [address(blues), address(pop)]);

        vm.deal(user, 1 * _amount);
        vm.startPrank(user);

        blues.mint{value: blues.TOKEN_PRICE() * _amount}(_amount);
        blues.approve(address(swapper), _amount);

        vm.expectRevert();
        swapper.swap(vm.addr(1), _amount);

        vm.stopPrank();
    }
}

contract Unit_Swapper_Unswap is Base {
    function test_TokenUnswap(uint128 _amount) public {
        vm.assume(_amount > 0); // Amount must be > 0

        blues = new Blues(1, 10000);
        pop = new Pop(1, 10000);
        swapper = new Swapper(100, [address(blues), address(pop)]);

        vm.deal(user, 1 * _amount);
        vm.startPrank(user);

        blues.mint{value: blues.TOKEN_PRICE() * _amount}(_amount);
        blues.approve(address(swapper), _amount);
        swapper.swap(address(blues), _amount);

        assertEq(blues.balanceOf(user), 0);
        assertEq(swapper.balanceOf(user), (_amount / swapper.tokenPrice()) * 10 ** 18);

        swapper.unswap(address(blues), _amount);

        assertEq(blues.balanceOf(user), _amount);
        assertEq(swapper.balanceOf(user), 0);

        vm.stopPrank();
    }

    function test_AmountZero(uint128 _amount) public {
        vm.assume(_amount > 0); // Amount must be > 0

        blues = new Blues(1, 10000);
        pop = new Pop(1, 10000);
        swapper = new Swapper(100, [address(blues), address(pop)]);

        vm.deal(user, 1 * _amount);
        vm.startPrank(user);

        blues.mint{value: blues.TOKEN_PRICE() * _amount}(_amount);
        blues.approve(address(swapper), _amount);
        swapper.swap(address(blues), _amount);

        assertEq(blues.balanceOf(user), 0);
        assertEq(swapper.balanceOf(user), (_amount / swapper.tokenPrice()) * 10 ** 18);

        vm.expectRevert();
        swapper.unswap(address(blues), 0);

        vm.stopPrank();
    }

    function test_WrongAddress(uint128 _amount) public {
        vm.assume(_amount > 0); // Amount must be > 0

        blues = new Blues(1, 10000);
        pop = new Pop(1, 10000);
        swapper = new Swapper(100, [address(blues), address(pop)]);

        vm.deal(user, 1 * _amount);
        vm.startPrank(user);

        pop.mint{value: pop.TOKEN_PRICE() * _amount}(_amount);
        pop.approve(address(swapper), _amount);
        swapper.swap(address(pop), _amount);

        assertEq(pop.balanceOf(user), 0);
        assertEq(swapper.balanceOf(user), (_amount / swapper.tokenPrice()) * 10 ** 18);

        vm.expectRevert();
        swapper.unswap(vm.addr(1), _amount); // vm.addr(1) is a non token address

        vm.stopPrank();
    }
}

contract Unit_Swapper_PriceSetter is Base {
    function test_SetPrice(uint128 _amount) public {
        uint256 newPrice = 200;

        vm.assume(_amount % newPrice == 0 && _amount > 1);

        blues = new Blues(1, 10000);
        pop = new Pop(1, 10000);
        swapper = new Swapper(100, [address(blues), address(pop)]);

        vm.deal(user, 1 * _amount);
        vm.startPrank(user);

        blues.mint{value: (blues.TOKEN_PRICE() * _amount)}(_amount);
        blues.approve(address(swapper), _amount);
        swapper.swap(address(blues), _amount);

        assertEq(blues.balanceOf(user), 0);
        assertEq(swapper.balanceOf(user), (_amount / swapper.tokenPrice()) * 10 ** 18);

        vm.stopPrank();

        swapper.setPrice(newPrice);

        swapper.balanceOf(user);

        vm.startPrank(user);
        swapper.unswap(address(blues), _amount);

        assertEq(blues.balanceOf(user), _amount);
        assertEq(swapper.balanceOf(user), (_amount / swapper.tokenPrice()) * 10 ** 18);
    }

    function test_SetPriceOwner(address _user, uint256 _price) public {
        blues = new Blues(1, 10000);
        pop = new Pop(1, 10000);
        swapper = new Swapper(100, [address(blues), address(pop)]);

        vm.assume(swapper.owner() != _user);

        vm.startPrank(_user);

        vm.expectRevert();
        swapper.setPrice(_price);

        vm.stopPrank();
    }
}
