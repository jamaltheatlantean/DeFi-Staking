// stake: Lock tokens into smart contract
// withdraw: unlock tokens and pull out of smart contract 
// reward: users get frequent reward tokens (ATNs) for their stakes.

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Staking__TransferFailed();
error Staking__NeedsMoreThanZero();

contract Staking {
    IERC20 public s_stakingToken;
    IERC20 public s_rewardToken;

    mapping (address => uint256) public s_balances;
    mapping (address => uint256) public s_userRewardPerTokenPaid; 
    mapping (address => uint256) public s_rewards;

    uint256 public constant REWARD_RATE = 100;
    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;

    modifier updateReward(address account){
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if( amount == 0){
            revert Staking__NeedsMoreThanZero();
        }
        _;
    }

    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }

    function earned(address account) public view returns(uint256){
        uint256 currentBalance = s_balances[account];
        // how much beneficiaries have been paid already
        uint256 amountPaid = s_userRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];
        uint256 _earned = ((currentBalance * (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;
        return _earned;
    }

    // based on how long it has been since the last snapshot
    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0){
            return s_rewardPerTokenStored;
        }
        return s_rewardPerTokenStored + (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) / s_totalSupply);
    }

    function stake(uint256 amount) external updateReward(msg.sender) moreThanZero(amount){
        // keep track of how much token user has staked
        // keep track of how much token user has
        // transfer the tokens to this contract
        //
        // increase how much user is staking from how much already staked
        s_balances[msg.sender] = s_balances[msg.sender] + amount;
        s_totalSupply = s_totalSupply + amount;
        // emit event
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        if(!success) {
            revert Staking__TransferFailed();
        }
    }

    function withdraw(uint256 amount) external updateReward(msg.sender) moreThanZero(amount){
        s_balances[msg.sender] = s_balances[msg.sender] - amount;
        s_totalSupply = s_totalSupply - amount;
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if(!success) {
            revert Staking__TransferFailed();
        }
    }

    function claimReward() external updateReward(msg.sender) {
        uint256 reward = s_rewards[msg.sender];
        bool success = s_rewardToken.transfer(msg.sender, reward);
        if (!success){
            revert Staking__TransferFailed();
        }
        //
        // contract emit x tokens/s
        // sends tokens to all tokenStakers
        //
        // staked tokens: 50 staked tokens, 30 staked tokens, 20 staked tokens
        // reward: 50 staked tokens, 30 staked tokens, 20 staked tokens
        //
        // 100 more tokens staked
        // staked: 100, 50, 30, 20
        // rewards: 50, 25, 15, 10

    }
}
