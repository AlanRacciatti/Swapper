// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import 'isolmate/tokens/ERC20.sol';

error WrongValue();
error ZeroTokens();

//// @title A token, called Blues :)
/// @author Chiin
/// @notice Simple token with mint function
/// @dev Token price is setted by the deployer
contract Blues is ERC20 {
    uint256 public immutable TOKEN_PRICE;

    constructor(uint256 _tokenPrice, uint256 _initialSupply) ERC20('Blues', 'BLUES', 18) {
        TOKEN_PRICE = _tokenPrice;
        _mint(msg.sender, _initialSupply * 10 ** decimals);
    }

    /// @notice Mints tokens
    /// @dev Ask for the exact amount of ETH to avoid using a dust collector
    /// @param _amount Amount of tokens to be minted
    function mint(uint256 _amount) external payable {
        if (_amount == 0) revert ZeroTokens();
        if (TOKEN_PRICE * _amount != msg.value) revert WrongValue();
        _mint(msg.sender, _amount);
    }
}

//// @title A token, called Pop :)
/// @author Chiin
/// @notice Simple token with mint function
/// @dev Token price is setted by the deployer
contract Pop is ERC20 {
    uint256 public immutable TOKEN_PRICE;

    constructor(uint256 _tokenPrice, uint256 _initialSupply) ERC20('Pop', 'POP', 18) {
        TOKEN_PRICE = _tokenPrice;
        _mint(msg.sender, _initialSupply * 10 ** decimals);
    }

    /// @notice Mints tokens
    /// @dev Ask for the exact amount of ETH to avoid using a dust collector
    /// @param _amount Amount of tokens to be minted
    function mint(uint256 _amount) external payable {
        if (_amount == 0) revert ZeroTokens();
        if (TOKEN_PRICE * _amount != msg.value) revert WrongValue();
        _mint(msg.sender, _amount);
    }
}
