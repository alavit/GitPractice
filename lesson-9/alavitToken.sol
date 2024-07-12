// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.20;

import "./myERC.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract alavitToken is myERC, Ownable {
  constructor(address initialOwner)
    myERC('AlavitToken)', 'ALVTK')
    Ownable(initialOwner)
  {}

  function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
  }
}