// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

abstract contract myERC is ERC20Pausable, ERC20Burnable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    }

    /**
     * @dev Overrides decimals to 10
     */
    function decimals() public view virtual override returns (uint8) {
        return 10;
    }

    // Override the burn functions to disable them
    function burn(uint256 value) public pure override {
        revert("Token burning is disabled");
    }

    function burnFrom(address account, uint256 amount) public pure override {
        revert("Token burning is disabled");
    }
    
    function _update(address from, address to, uint256 value) internal virtual override(ERC20, ERC20Pausable) whenNotPaused {
        super._update(from, to, value);
    }
}