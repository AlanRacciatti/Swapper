// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {DSTestFull} from 'test/utils/DSTestFull.sol';
import {console} from 'forge-std/console.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

import {Pop, Blues} from 'contracts/HelperTokens.sol';
import {Swapper} from 'contracts/Swapper.sol';

contract CommonE2EBase is DSTestFull {
    uint256 constant FORK_BLOCK = 15452788;
    uint256 constant INITIAL_SUPPLY = 100 ether;

    address user = label('user');
    address owner = label('owner');
    Blues blues;
    Pop pop;
    Swapper swapper;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('mainnet'), FORK_BLOCK);
        vm.startPrank(owner);

        blues = new Blues(1 ether, INITIAL_SUPPLY);
        pop = new Pop(1 ether, INITIAL_SUPPLY);
        swapper = new Swapper(1, [address(blues), address(pop)]);

        vm.stopPrank();
    }
}
