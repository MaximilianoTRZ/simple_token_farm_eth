// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./DappToken.sol";
import "./LPToken.sol";

/**
    A super simple token farm
*/
contract TokenFarm {

    //
    // State variables
    //
    string public name = "Simple Token Farm";

    address public owner;
    DappToken public dappToken; //mock platform reward token
    LPToken public lpToken; // mock LP Token staked by users

    // rewards per block
    uint256 public constant REWARD_PER_BLOCK = 1e18;

    // iterable list of staking users
    address[] public stakers;

    // users staking and rewards info
    // mapping(address => uint256) public stakingBalance;
    // mapping(address => uint256) public checkpoints;
    // mapping(address => uint256) public pendingRewards;
    // mapping(address => bool) public hasStaked;
    // mapping(address => bool) public isStaking;

    struct User {
        uint256 stakingBalance;
        uint256 checkpoint;
        uint256 pendingRewards;
        bool hasStaked;
        bool isStaking;
    }
    mapping (address => User) public users;


    // Events - add events as needed
    event LogDepositMade(
        address accountAddress,
        uint amount
    );

    event LogWithdrawal(
        address accountAddress,
        uint amount
    );

    event LogClaimedReward(
        address accountAddress,
        uint amount
    );

    event LogRewardsUpdated(
        uint rewardedUsers
    );


    // Modifiers
    modifier onlyStakingUser {
        require(
            users[msg.sender].isStaking,
            "Caller is not a staking user"
        );
        _;
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Caller is not the owner"
        );
        _;
    }


    /**
        constructor
     */
    constructor(DappToken _dappToken, LPToken _lpToken) {
        // Set the owner to the creator of this contract
        owner = msg.sender;

        // Set the instance of the deployed Dapp and LP contracts
        lpToken = _lpToken;
        dappToken = _dappToken;
    }

    /**
     @notice Deposit
     Users deposits LP Tokens
     */
    function deposit(uint256 _amount) public {
        // Require amount greater than 0
        require(_amount > 0, "Amount is 0");

        address _userAddr = msg.sender;
        User storage _user = users[_userAddr];

        // Transfer Mock LP Tokens to this contract for staking
        lpToken.transferFrom(_userAddr, address(this), _amount);

        // Update staking balance
        _user.stakingBalance += _amount;

        // Add user to stakers array only if they haven't staked already
        if (!_user.hasStaked) {
            stakers.push(_userAddr);
        }

        // Update staking status
        _user.isStaking = true;
        _user.hasStaked = true;

        // checkpoint block number
        if (_user.checkpoint == 0) {
            _user.checkpoint = block.number;
        }

        // calculate rewards
        distributeRewards(_userAddr);

        // emit some event
        emit LogDepositMade(_userAddr, _amount);
    }

    /**
     @notice Withdraw
     Unstaking LP Tokens (Withdraw all LP Tokens)
     */
    function withdraw() public onlyStakingUser {
        address _userAddr = msg.sender;
        User storage _user = users[_userAddr];

        // check is sender is staking
        // require(isStaking[_user], "User is not staking");

        // Fetch staking balance
        uint256 balance = _user.stakingBalance;

        // Require amount greater than 0
        require(balance > 0, "Insufficient LPT");

        // calculate rewards before reseting staking balance
        distributeRewards(_userAddr);

        // Reset staking balance
        _user.stakingBalance = 0;

        // Update staking status
        _user.isStaking = false;

        // emit some event
        emit LogWithdrawal(_userAddr, balance);

        // Transfer LP Tokens to user
        lpToken.transfer(_userAddr, balance);
    }

    /**
     @notice Claim Rewards
     Users claim pending rewards
     Pending rewards are minted to the user
     */
    function claimRewards() public {
        address _userAddr = msg.sender;
        User storage _user = users[_userAddr];

        // fetch pending rewards
        uint256 pendingAmount = _user.pendingRewards;

        // check if user has pending rewards
        require(pendingAmount > 0, "User has no pending rewards");

        // reset pending rewards balance
        _user.pendingRewards = 0;

        // mint rewards tokens to user
        dappToken.mint(_userAddr, pendingAmount);

        // emit some event
        emit LogClaimedReward(_userAddr, pendingAmount);
    }

    /**
     @notice Distribute rewards 
     Distribute rewards for all staking users
     */
    function distributeRewardsAll() external onlyOwner {
        // Only owner can call this function
        // require(msg.sender == owner, "Caller is not the owner");

        // set rewards to all stakers
        // in this case the iterable list of staking users could be useful
        for (uint256 i = 0; i < stakers.length; i++) {
            distributeRewards(stakers[i]);
        }

        // emit some event
        emit LogRewardsUpdated(stakers.length);
    }

    /**
     @notice Distribute rewards
     calculates rewards for the indicated beneficiary
     */
    function distributeRewards(address beneficiary) private {
        User storage _user = users[beneficiary];

        // get last checkpoint block
        uint256 checkpoint = _user.checkpoint;

        // calculates rewards
        // updates pending rewards and block number checkpoint
        if (block.number > checkpoint) {
            // blocks-since-last-checkpoint
            uint256 blocksSince = block.number - checkpoint;

            // reward = beneficiary balance * ( blocks-since-last-checkpoint * REWARD_PER_BLOCK )
            uint256 reward = _user.stakingBalance * blocksSince * REWARD_PER_BLOCK;

            _user.pendingRewards = reward;

            // update checkpoint
            _user.checkpoint = block.number;
        }
    }
}