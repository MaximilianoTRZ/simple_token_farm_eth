import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  DappToken,
  DappToken__factory,
  LPToken,
  LPToken__factory,
  TokenFarm,
  TokenFarm__factory,
} from "../typechain";
import { BigNumber } from "ethers";

describe("TokenFarm Contract", function () {
  let DappToken: DappToken__factory;
  let dappToken: DappToken;
  let LpToken: LPToken__factory;
  let lpToken: LPToken;

  let TokenFarm: TokenFarm__factory;
  let tokenFarm: TokenFarm;

  let owner: SignerWithAddress;
  let user1: SignerWithAddress;
  let user2: SignerWithAddress;
  let user3: SignerWithAddress;

  // Amount of LPT to deposit
  const amountToDeposit = ethers.utils.parseUnits("1", 18);

  this.beforeAll(async () => {
    DappToken = await ethers.getContractFactory("DappToken");
    dappToken = await DappToken.deploy();

    LpToken = await ethers.getContractFactory("LPToken");
    lpToken = await LpToken.deploy();

    TokenFarm = await ethers.getContractFactory("TokenFarm");
    tokenFarm = await TokenFarm.deploy(dappToken.address, lpToken.address);

    // Give tokenFarm access to dappToken mint function
    await dappToken.toggleController(tokenFarm.address);

    [owner, user1, user2, user3] = await ethers.getSigners();
  });

  describe("Deployment", () => {
    it("Sets the right owner", async () => {
      expect(await tokenFarm.owner()).to.equal(owner.address);
    });
  });

  describe("LPT Deposits", () => {
    it("Takes a deposit of the correct amount", async () => {
      const user = user1;

      // Mint LPT for user
      await lpToken.mint(user.address, amountToDeposit);

      // Approve transfer of tokens
      await lpToken.connect(user).approve(tokenFarm.address, amountToDeposit);
      // Deposit tokens
      await tokenFarm.connect(user).deposit(amountToDeposit);

      // Fetch user info
      const userInfo = await tokenFarm.users(user.address);

      expect(userInfo.stakingBalance.eq(amountToDeposit)).to.be.true;
      expect(userInfo.hasStaked).to.be.true;
      expect(userInfo.isStaking).to.be.true;
    });

    it("Emits LogDepositMade event", async () => {
      const user = user2;
      const amount = amountToDeposit.mul(BigNumber.from("2"));

      await lpToken.mint(user.address, amount);
      await lpToken.connect(user).approve(tokenFarm.address, amount);

      await expect(tokenFarm.connect(user).deposit(amount))
        .to.emit(tokenFarm, "LogDepositMade")
        .withArgs(user.address, amount);
    });
  });

  describe("DAPP Rewards", () => {
    it("Correctly distributes rewards to all staking users", async () => {
      // Let's make another deposit (from user3)
      await lpToken.mint(user3.address, amountToDeposit);
      await lpToken.connect(user3).approve(tokenFarm.address, amountToDeposit);
      await tokenFarm.connect(user3).deposit(amountToDeposit);

      const users = [user1, user2, user3];
      let checkpoints: BigNumber[] = [];

      // Pending rewards should be 0 for all users
      for (let i = 0; i < users.length; i++) {
        const userInfo = await tokenFarm.users(users[i].address);

        checkpoints[i] = userInfo.checkpoint;

        expect(userInfo.isStaking).to.be.true;
        expect(userInfo.pendingRewards.eq(BigNumber.from("0"))).to.be.true;
      }

      // Distribute all rewards
      const tx = await tokenFarm.distributeRewardsAll();
      const receipt = await tx.wait();

      // Users' pending rewards should be equal to the respective estimated reward
      for (let i = 0; i < users.length; i++) {
        const userInfo = await tokenFarm.users(users[i].address);

        // Get number of blocks since the latest checkpoint
        const blocksSince = BigNumber.from(receipt.blockNumber).sub(
          checkpoints[i]
        );

        // Estimate user's pending rewards
        const estimatedReward = userInfo.stakingBalance
          .mul(blocksSince)
          .mul(await tokenFarm.REWARD_PER_BLOCK());

        expect(userInfo.pendingRewards.eq(estimatedReward)).to.be.true;
      }
    });

    it("Sends the correct amount when user claims rewards", async () => {
      const user = user1;

      // User's DAPP balance
      const oldDappBalance = await dappToken.balanceOf(user.address);

      // Fetch user info
      const userInfo = await tokenFarm.users(user.address);

      // Claim rewards
      await tokenFarm.connect(user).claimRewards();

      // Current user's DAPP balance
      const dappBalance = await dappToken.balanceOf(user.address);

      // The current user's DAPP balance should be equal to the old one plus the
      // claimed rewards
      expect(dappBalance.eq(oldDappBalance.add(userInfo.pendingRewards))).to.be
        .true;
    });

    it("Emits LogClaimedReward event when user claims rewards", async () => {
      const user = user2;

      await expect(tokenFarm.connect(user).claimRewards()).to.emit(
        tokenFarm,
        "LogClaimedReward"
      );
    });

    it("Emits LogRewardsUpdated event when owner distributes rewards", async () => {
      await expect(tokenFarm.distributeRewardsAll()).to.emit(
        tokenFarm,
        "LogRewardsUpdated"
      );
    });
  });

  describe("LPT Withdrawals", () => {
    it("Allows user to withdraw staked tokens", async () => {
      const user = user1;

      // User's LPT balance
      const oldLptBalance = await lpToken.balanceOf(user.address);

      // Fetch user info
      let userInfo = await tokenFarm.users(user.address);

      // Withdraw staked tokens
      await tokenFarm.connect(user).withdraw();

      // Current user's LPT balance
      const lptBalance = await lpToken.balanceOf(user.address);

      // The current user's LPT balance should be equal to the old one plus the
      // unstaked tokens
      expect(lptBalance.eq(oldLptBalance.add(userInfo.stakingBalance))).to.be
        .true;

      // The user should not be staking after withdrawing
      // Re-fetch user info
      userInfo = await tokenFarm.users(user.address);
      expect(userInfo.isStaking).not.to.be.true;
      expect(userInfo.hasStaked).to.be.true;
    });

    it("Allows user to claim pending rewards after withdrawing", async () => {
      const user = user1;
      const userInfo = await tokenFarm.users(user.address);

      if (userInfo.pendingRewards.gt(BigNumber.from("0"))) {
        await expect(tokenFarm.connect(user).claimRewards()).not.to.be.reverted;
      }
    });

    it("Emits LogWithdrawal event", async () => {
      const user = user3;

      await expect(tokenFarm.connect(user).withdraw())
        .to.emit(tokenFarm, "LogWithdrawal")
        .withArgs(user.address, amountToDeposit);
    });
  });
});
