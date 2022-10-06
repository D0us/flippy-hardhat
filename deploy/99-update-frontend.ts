import { ethers, network } from "hardhat"
import * as fs from "fs"

const FRONT_END_ADDRESSES_FILE = "../flippy-web/constants/contractAddresses.json"
const FRONT_END_ABI_FILE = "../flippy-web/constants/abi.json"

module.exports = async () => {
    if (process.env.UPDATE_FRONT_END) {
        console.log("updating front end")
    }
    await updateContractAddresses()
    await updateAbi()
}

async function updateAbi() {
    const flippy = await ethers.getContract("Flippy")
    fs.writeFileSync(FRONT_END_ABI_FILE, flippy.interface.format(ethers.utils.FormatTypes.json).toString())
}

async function updateContractAddresses() {
    const flippy = await ethers.getContract("Flippy")

    let currentAddresses
    if (fs.existsSync(FRONT_END_ADDRESSES_FILE)) {
        currentAddresses = JSON.parse(fs.readFileSync(FRONT_END_ADDRESSES_FILE, "utf8"))
    } else {
        currentAddresses = {}
    }

    const chainId: string | undefined = network.config.chainId?.toString()

    if (!chainId) {
        console.log("No chain Id set")
        process.exit(0)
    }
    console.log("next")

    if (chainId in currentAddresses) {
        if (!currentAddresses[chainId].includes(flippy.address)) {
            currentAddresses[chainId].push(flippy.address)
        }
    } else {
        currentAddresses[chainId] = [flippy.address]
    }
    fs.writeFileSync(FRONT_END_ADDRESSES_FILE, JSON.stringify(currentAddresses))
}

module.exports.tags = ["all", "frontend"]
