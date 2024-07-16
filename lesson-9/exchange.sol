// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0)

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

using SafeERC20 for IERC20;

contract Exchange {
    IERC20 public godToken;
    IERC20 public devilToken;
    uint256 public rate = 1000; // Rate of exchange (1 ETH = 1000 tokens)

    event BoughtTokens(address indexed buyer, address token, uint256 amount);
    event SwappedTokens(
        address indexed swapper,
        address fromToken,
        address toToken,
        uint256 amount
    );

    constructor(IERC20 _godToken, IERC20 _devilToken) {
        godToken = _godToken;
        devilToken = _devilToken;
    }

    function buyGodTokens() public payable {
        uint256 amountToBuy = msg.value * rate;
        require(
            godToken.balanceOf(address(this)) >= amountToBuy,
            "Not enough tokens in the reserve"
        );
        godToken.safeTransfer(msg.sender, amountToBuy);
        emit BoughtTokens(msg.sender, address(godToken), amountToBuy);
    }

    function buyDevilTokens() public payable {
        uint256 amountToBuy = msg.value * rate;
        require(
            devilToken.balanceOf(address(this)) >= amountToBuy,
            "Not enough tokens in the reserve"
        );
        devilToken.safeTransfer(msg.sender, amountToBuy);
        emit BoughtTokens(msg.sender, address(devilToken), amountToBuy);
    }

    function swapGodToDevil(uint256 amount) public {
        require(
            godToken.allowance(msg.sender, address(this)) >= amount,
            "Token allowance too low"
        );
        require(godToken.balanceOf(msg.sender) >= amount, "Not enough tokens");

        godToken.safeTransferFrom(msg.sender, address(this), amount);
        devilToken.safeTransfer(msg.sender, amount);

        emit SwappedTokens(
            msg.sender,
            address(godToken),
            address(devilToken),
            amount
        );
    }

    function swapDevilToGod(uint256 amount) public {
        require(
            devilToken.allowance(msg.sender, address(this)) >= amount,
            "Token allowance too low"
        );
        require(
            devilToken.balanceOf(msg.sender) >= amount,
            "Not enough tokens"
        );

        devilToken.safeTransferFrom(msg.sender, address(this), amount);
        godToken.safeTransfer(msg.sender, amount);

        emit SwappedTokens(
            msg.sender,
            address(devilToken),
            address(godToken),
            amount
        );
    }
}