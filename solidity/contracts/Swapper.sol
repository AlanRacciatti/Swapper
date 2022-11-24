// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import 'isolmate/tokens/ERC20.sol';
import 'isolmate/interfaces/tokens/IERC20.sol';
import 'openzeppelin-contracts/access/Ownable.sol';

error UnallowedToken();
error ZeroTokens();
error TransferError();

contract Swapper is ERC20, Ownable {
    uint256 public tokenPrice; // Works as getter function
    address[2] public allowedTokens;

    /// @param _tokenPrice Price of the token, amount of ROCK tokens to buy POP or BLUES tokens
    /// @param _allowedTokens The two tokens (POP & BLUES) from which users can swap
    constructor(uint256 _tokenPrice, address[2] memory _allowedTokens) ERC20('Rock', 'ROCK', 18) {
        allowedTokens = _allowedTokens;
        tokenPrice = _tokenPrice;
    }

    modifier onlyAllowedToken(address _token) {
        if (_token != allowedTokens[0] && _token != allowedTokens[1]) revert UnallowedToken();
        _;
    }

    /// @notice Converts an amount of input _token to an equivalent amount of the output token
    /// @param _token address of token to swap
    /// @param amount amount of token to swap/receive
    function swap(address _token, uint256 amount) external onlyAllowedToken(_token) {
        if (amount == 0) revert ZeroTokens();

        IERC20 token = IERC20(_token);
        if (!token.transferFrom(msg.sender, address(this), amount)) revert TransferError();
        _mint(msg.sender, (amount / tokenPrice) * 10 ** 18);
    }

    /// @notice Converts an amount of input _token to an equivalent amount of the output token
    /// @param _token address of token to receive
    /// @param amount amount of token to swap/receive
    function unswap(address _token, uint256 amount) external onlyAllowedToken(_token) {
        if (amount == 0) revert ZeroTokens();

        IERC20 token = IERC20(_token);
        if (!token.transfer(msg.sender, amount)) revert TransferError();
        _burn(msg.sender, (amount / tokenPrice) * 10 ** 18);
    }

    function setPrice(uint256 _tokenPrice) external onlyOwner {
        tokenPrice = _tokenPrice;
    }
}
