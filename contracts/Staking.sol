// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Staking__TransferFailed();
error Staking__NeedsMoreThanZero();

// stake: Lock tokens into smart contract
// withdraw: unlock tokens and pull out of smart contract
// reward: users get frequent reward tokens (ATNs) for their stakes.

contract Staking {
    IERC20 public s_stakingToken;
    IERC20 public s_rewardToken;

    address public owner;
    // user address => staked amount
    mapping(address => uint) public s_balances;
    // user address => rewardPerTokenStored
    mapping(address => uint) public s_userRewardPerTokenPaid;
    // user address => rewards to be claimed
    mapping(address => uint) public s_rewards;

    // timestamp of when rewards finish
    uint public finishAt;
    // minimum of last updated time and reward finsih time
    uint public updatedAt;
    // duration of rewards to be paid in seconds
    uint public duration;
    // reward rate to be paid out per second
    uint public rewardRate = 100;
    // total amount staked
    uint public s_totalSupply;
    // sum of reward rate * duration * 1e18 / total supply
    uint public s_rewardPerTokenStored;
    // minimum of last updated time and reward finish time
    uint public s_lastUpdateTime;

    // MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner, "warning: not owner");
        _;
    }

    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    modifier moreThanZero(uint amount) {
        if (amount == 0) {
            revert Staking__NeedsMoreThanZero();
        }
        _;
    }
    
    constructor(address stakingToken, address rewardToken) {
        owner = msg.sender;
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }

    function earned(address account) public view returns (uint) {
        uint currentBalance = s_balances[account];
        // how much beneficiaries have been paid already
        uint amountPaid = s_userRewardPerTokenPaid[account];
        uint currentRewardPerToken = rewardPerToken();
        uint pastRewards = s_rewards[account];
        uint _earned = ((currentBalance *
            (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;
        return _earned;
    }

    // based on how long it has been since the last snapshot
    function rewardPerToken() public view returns (uint) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return
            s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * rewardRate * 1e18) /
                s_totalSupply);
    }

    function stake(uint amount)
        external
        updateReward(msg.sender)
        moreThanZero(amount)
    {
        // keep track of how much token user has staked
        // keep track of how much token user has
        // transfer the tokens to this contract
        //
        // increase how much user is staking from how much already staked
        s_balances[msg.sender] = s_balances[msg.sender] + amount;
        s_totalSupply = s_totalSupply + amount;
        // emit event
        bool success = s_stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) revert Staking__TransferFailed();
    }

    function withdraw(uint amount)
        public
        updateReward(msg.sender)
        moreThanZero(amount)
    {
        require(amount > 0,"warning: cannot withdraw 0");
        s_balances[msg.sender] = s_balances[msg.sender] - amount;
        s_totalSupply = s_totalSupply - amount;
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function claimReward() external updateReward(msg.sender) {
        uint reward = s_rewards[msg.sender];
        bool success = s_rewardToken.transfer(msg.sender, reward);
        if (!success) {
            revert Staking__TransferFailed();
        }
        // how would tokenStakers get?
        //
        // contract emit 'x' tokens/s || token per second
        // sends tokens to all tokenStakers
        //
        // contract generates 100 tokens/s 
        // staked tokens: 50 staked tokens, 30 staked tokens, 20 staked tokens
        // reward: 50 staked tokens, 30 staked tokens, 20 staked tokens
        //
        // 100 more tokens staked
        // staked: 100, 50, 30, 20
        // rewards: 50, 25, 15, 10
    }

    function setRewardDuration(uint _duration) external onlyOwner {
        require(finishAt < block.timestamp, "warning: duration not finished");
        duration = _duration;
    }
}

