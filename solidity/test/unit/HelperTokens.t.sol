// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <0.9.0;

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';
import {DSTestFull} from 'test/utils/DSTestFull.sol';
import {Blues, Pop} from 'contracts/HelperTokens.sol';

abstract contract Base is DSTestFull {
    address user = label('user');
    Blues blues;
    Pop pop;
}

contract Unit_Helper_Tokens_Constructor is Base {
    function test_TokenPrice(uint256 _tokenPrice) public {
        blues = new Blues(_tokenPrice, 10000);
        pop = new Pop(_tokenPrice, 10000);

        assertEq(blues.TOKEN_PRICE(), _tokenPrice);
        assertEq(pop.TOKEN_PRICE(), _tokenPrice);
    }

    /// @dev Using uint128 instead of uint256 for fuzzing because overflow
    function test_InitialSupply(uint128 _initialSupply) public {
        blues = new Blues(1 ether, _initialSupply);
        pop = new Pop(1 ether, _initialSupply);

        assertEq(blues.totalSupply(), _initialSupply * 10 ** blues.decimals());
        assertEq(pop.totalSupply(), _initialSupply * 10 ** pop.decimals());
    }
}

contract Unit_Helper_Tokens_Mint is Base {
    /// @dev Using uint128 instead of uint256 because overflow if dealing amount * token_price
    function test_Mint(uint128 _amount) public {
        vm.deal(user, type(uint256).max);
        vm.assume(_amount > 0); // If amount == 0 test fails

        blues = new Blues(1 ether, 10000);
        pop = new Pop(1 ether, 10000);

        vm.startPrank(user);

        assertEq(blues.balanceOf(user), 0);
        assertEq(pop.balanceOf(user), 0);

        blues.mint{value: _amount * blues.TOKEN_PRICE()}(_amount);
        pop.mint{value: _amount * pop.TOKEN_PRICE()}(_amount);

        assertEq(blues.balanceOf(user), _amount);
        assertEq(pop.balanceOf(user), _amount);

        vm.stopPrank();
    }

    /// @dev Using uint128 instead of uint256 because overflow if dealing amount * token_price
    function test_Mint_Error(uint128 _amount) public {
        vm.deal(user, type(uint256).max);

        blues = new Blues(1 ether, 10000);
        pop = new Pop(1 ether, 10000);

        vm.startPrank(user);

        assertEq(blues.balanceOf(user), 0);
        assertEq(pop.balanceOf(user), 0);

        vm.expectRevert();
        blues.mint{value: _amount * 10 ether}(_amount);

        vm.expectRevert();
        blues.mint(_amount);

        vm.expectRevert();
        pop.mint{value: _amount * 10 ether}(_amount);

        vm.expectRevert();
        pop.mint(_amount);

        assertEq(blues.balanceOf(user), 0);
        assertEq(pop.balanceOf(user), 0);

        vm.stopPrank();
    }
}
