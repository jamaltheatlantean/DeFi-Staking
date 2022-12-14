// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Reward users ATN tokens for their stake
contract RewardToken is ERC20 {
    constructor() ERC20("AtlanteanNotes", "ATN") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}
