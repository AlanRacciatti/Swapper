// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Script} from 'forge-std/Script.sol';
import {Blues, Pop} from 'contracts/HelperTokens.sol';
import {Swapper} from 'contracts/Swapper.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

abstract contract Deploy is Script {
    function _deploy(uint256 _tokenPrice, uint256 _initialSupply) internal {
        address blues;
        address pop;

        vm.startBroadcast();
        blues = address(new Blues(_tokenPrice, _initialSupply));
        pop = address(new Pop(_tokenPrice, _initialSupply));
        new Swapper(1, [blues, pop]);
        vm.stopBroadcast();
    }
}

contract DeployMainnet is Deploy {
    function run() external {
        uint256 TOKEN_PRICE = 0.01 ether;
        uint256 INITIAL_SUPPLY = 100 ether;

        _deploy(TOKEN_PRICE, INITIAL_SUPPLY);
    }
}

contract DeployMumbai is Deploy {
    function run() external {
        uint256 TOKEN_PRICE = 0.01 ether;
        uint256 INITIAL_SUPPLY = 100 ether;

        _deploy(TOKEN_PRICE, INITIAL_SUPPLY);
    }
}
