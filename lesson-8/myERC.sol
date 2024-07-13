// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

abstract contract myERC is ERC20Pausable, ERC20Burnable {
    mapping(address => bool) public blacklist;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    }

    /**
     * @dev Adds address to blacklist
     */
    function addToBlacklist(address _addr) external {
        blacklist[_addr] = true;
    }

    /**
     * @dev Removes address from blacklist
     */
    function removeFromBlacklist(address _addr) external {
        blacklist[_addr] = false;
    }

    modifier notBlacklisted(address _account) {
        require(!blacklist[_account], "Sender is blacklisted");
        _;
    }

    /**
     * @dev Overrides decimals to 10
     */
    function decimals() public view virtual override returns (uint8) {
        return 10;
    }

    /**
     * @dev Overrides transfer function to check if the sender and/or spender is not blacklisted
     */
    function approve(address spender, uint256 value) public virtual override notBlacklisted(_msgSender()) notBlacklisted(spender) returns (bool) {
        return super.approve(spender, value);
    }

    function transferFrom(address from, address to, uint256 value) public virtual override notBlacklisted(from) notBlacklisted(to) returns (bool) {
        return super.transferFrom(from, to, value);
    }

    /**
     * @dev Disables burning
     */
    function burn(uint256 value) public view override notBlacklisted(_msgSender()) {
        revert("Token burning is disabled");
    }

    /**
     * @dev Disables burning from address
     */
    function burnFrom(address account, uint256 amount) public view override notBlacklisted(_msgSender()) notBlacklisted(account) {
        revert("Token burning is disabled");
    }
    
    /**
     * @dev Perform update if the contract is not paused
     */
    function _update(address from, address to, uint256 value) internal virtual override(ERC20, ERC20Pausable) whenNotPaused notBlacklisted(from) notBlacklisted(to){
        super._update(from, to, value);
    }
}