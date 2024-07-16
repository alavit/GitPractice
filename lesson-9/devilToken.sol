// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0)

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DevilToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("DevilToken", "DVLTK") {
        _mint(msg.sender, initialSupply);
    }
}