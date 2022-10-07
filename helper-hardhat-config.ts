import { ethers } from "hardhat"
import { BigNumber } from "ethers"

export interface networkConfigItem {
    name?: string
    minimumWager: BigNumber
    feePercentage: string
}
export interface networkConfigInfo {
    [key: number]: networkConfigItem
}

export const networkConfig: networkConfigInfo = {
    5: {
        name: "goerli",
        minimumWager: ethers.utils.parseEther("0.1"),
        feePercentage: "1",
    },
    31337: {
        name: "hardhat",
        minimumWager: ethers.utils.parseEther("0.1"),
        feePercentage: "1",
    },
}
export const developmentChains = ["hardhat", "localhost"]
