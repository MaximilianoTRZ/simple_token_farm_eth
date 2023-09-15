// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
    the DappToken mock represent the platform reward token 
 */
contract DappToken is ERC20("DApp Token", "DAPP"), Ownable {
    mapping(address => bool) private _controllers;

    function toggleController(address controller) external onlyOwner {
        _controllers[controller] = !_controllers[controller];
    }

    // implement the mint function
    function mint(address _to, uint256 _amount) public {
        require(_controllers[msg.sender], "Only controllers can mint");
        _mint(_to, _amount);
    }
}