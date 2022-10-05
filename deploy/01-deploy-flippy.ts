import { DeployFunction } from "hardhat-deploy/types"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { verify } from "../utils/verify"
import { developmentChains, networkConfig } from "../helper-hardhat-config"

const deployRaffle = async (hre: HardhatRuntimeEnvironment) => {
    const { deployments, getNamedAccounts, network, ethers } = hre

    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    let chainId = network.config.chainId
    if (!chainId) {
        chainId = 31337
    }

    const args = [
        deployer,
        networkConfig[chainId]["minimumWager"],
        0x00,
        // networkConfig[chainId]["fee"]
    ]

    console.log(`deploying to ${network.name}`)

    const flippy = await deploy("Flippy", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: 1,
    })

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(flippy.address, args)
    }
    log("------------------------------------")
}
export default deployRaffle
deployRaffle.tags = ["all", "raffle"]
