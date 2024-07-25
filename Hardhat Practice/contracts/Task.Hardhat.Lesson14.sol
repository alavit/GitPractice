// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

using SafeERC20 for IERC20;

abstract contract Dex is Ownable {
    address public token1;
    address public token2;
    constructor() {}

    /**
     * @notice  Sets the addresses of two tokens for the contract.
     * @dev     Tokens are saved into contract's state vatiables. This function is restricted to the contract's owner.
     * @param   _token1 The address of the first token.
     * @param   _token2 The address of the second token.
     */
    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    /**
     * @notice  Adds liquidity to the contract by transferring a specified amount of tokens
     * @dev     This function can only be called by the contract owner due to the `onlyOwner` modifier.
     * @param   token_address  The address of the ERC20 token to be transferred into the contract.
     * @param   amount The amount of tokens to be transferred.
     */
    function addLiquidity(address token_address, uint amount) public onlyOwner {
        IERC20(token_address).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
    }

    /**
     * @notice Swaps a specified amount of one token for another at the current swap rate.
     * @dev This function requires that the swap is between token1 and token2 only. It checks the sender's balance for sufficiency, calculates the swap amount using `getSwapPrice`, transfers the `amount` of `from` token to the contract, and then transfers the calculated `swapAmount` of `to` token from the contract to the sender. The function ensures the contract has enough allowance to perform the `to` token transfer.
     * @param from The address of the token being swapped from.
     * @param to The address of the token being swapped to.
     * @param amount The amount of the `from` token to swap.
     */
    function swap(address from, address to, uint amount) public {
        require(
            (from == token1 && to == token2) ||
                (from == token2 && to == token1),
            "Invalid tokens"
        );
        require(
            IERC20(from).balanceOf(msg.sender) >= amount,
            "Not enough to swap"
        );
        uint swapAmount = getSwapPrice(from, to, amount);
        IERC20(from).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(to).forceApprove(address(this), swapAmount);
        IERC20(to).safeTransferFrom(address(this), msg.sender, swapAmount);
    }

    /**
     * @notice Calculates the swap price between two tokens based on their current balances within the contract.
     * @dev This function returns the price of swapping `amount` of `from` token to `to` token, using the formula (amount * balanceOf(to)) / balanceOf(from). It is a view function, meaning it reads state but does not modify it.
     * @param from The address of the token being swapped from.
     * @param to The address of the token being swapped to.
     * @param amount The amount of the `from` token to be swapped.
     * @return The calculated amount of `to` token that `amount` of `from` token can be swapped for, based on the current balances within the contract.
     */
    function getSwapPrice(
        address from,
        address to,
        uint amount
    ) public view returns (uint) {
        return ((amount * IERC20(to).balanceOf(address(this))) /
            IERC20(from).balanceOf(address(this)));
    }

    /**
     * @notice Approves a spender to use a specified amount of both token1 and token2 on behalf of the caller.
     * @dev Calls the `approve` function on both `token1` and `token2` contracts, allowing `spender` to spend up to `amount` of each token on behalf of `msg.sender`.
     * @param amount The maximum amount of tokens the spender is allowed to use.
     */
    function approve(address spender, uint amount) public {
        SwappableToken(token1).approve(msg.sender, spender, amount);
        SwappableToken(token2).approve(msg.sender, spender, amount);
    }

    /**
     * @notice Returns the balance of a given token for a specified account.
     * @dev Calls the `balanceOf` function of the ERC20 token contract identified by `token` to get the balance of `account`. This is a view function, meaning it reads data from the blockchain without making any state changes.
     * @param token The address of the ERC20 token contract.
     * @param account The address of the account whose balance is being queried.
     * @return The balance of `account` for the token specified by `token`.
     */
    function balanceOf(
        address token,
        address account
    ) public view returns (uint) {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableToken is ERC20 {
    address private _dex;
    constructor(
        address dexInstance,
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    /**
     * @notice Approves `spender` to spend `amount` of tokens on behalf of `owner`.
     * @dev Overrides the `_approve` function with an additional check to prevent the DEX itself from being set as an approver. This is to ensure that only external addresses can be approved to spend tokens, enhancing security. If the `owner` is the DEX address, it reverts with "InvalidApprover".
     * @param owner The address of the token owner who is giving the approval.
     * @param spender The address of the party being given the right to spend the tokens.
     * @param amount The number of tokens `spender` is allowed to spend on behalf of `owner`.
     */
    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}
