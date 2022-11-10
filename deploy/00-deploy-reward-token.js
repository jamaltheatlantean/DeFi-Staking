module.exports = async({getNamedAccounts, deployments}) =>{
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    console.log("Deploying Atlantean Notes as Reward Tokens...")
    const rewardToken = await deploy("RewardToken", {
        from: deployer,
        args: [],
        log: true,
    })
    console.log("________________Notes deployed________________")
}

module.exports.tags = ["all", "rewardToken"]