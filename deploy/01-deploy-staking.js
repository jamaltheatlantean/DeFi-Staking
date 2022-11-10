const { ethers } = require("hardhat")

module.exports = async({getNamedAccounts, deployments}) =>{
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    const rewardToken = await ethers.getContract("RewardToken")
    console.log("Ready to deploy Staking Contract...")

    const staking = await deploy("Staking", {
        from: deployer,
        args: [rewardToken.address, rewardToken.address],
        log: true,
    })
    console.log("________________Deployed Contracts ________________")
}

module.exports.tags = ["all", "staking"]