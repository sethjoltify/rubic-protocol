import { Wallet, Web3Provider } from 'zksync-web3'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { Deployer } from '@matterlabs/hardhat-zksync-deploy'
import { DEFAULT_PRIVATE_KEY } from '../hardhat.config'
import { ethers } from 'hardhat'
import { AbiCoder } from 'ethers/lib/utils'

export default async function (hre: HardhatRuntimeEnvironment) {
    console.log(`Running update FeeFacet script`)
  
    // Initialize the wallet.
    const wallet = new Wallet(DEFAULT_PRIVATE_KEY)
 
    const DiamondABI = require("../diamondABI/diamond.json");

    // Create deployer object and load the artifact of the contract we want to deploy.
    const deployer = new Deployer(hre, wallet)
    // Load contract

    const Diamond = await ethers.getContractAt(DiamondABI,"0x9C57699576725ce531C4878DBe0E053B2f4A3619");
    const caller = await ethers.provider.getSigner("0x1f15Ce1561C47B9c4233e378d30E872c040D5aBB");

    const integratorInfo = {"isIntegrator":"true", "tokenFee":"3000", "RubicTokenShare":"500000", "RubicFixedCryptoShare":"0", "fixedFeeAmount":"0" };

    await Diamond.setIntegratorInfo("0xbD8e73Dc667e8B5a231e525a6d5405c832B61030", integratorInfo);


    // Deploy this contract. The returned object will be of a `Contract` type,
    // similar to the ones in `ethers`.
  
    // Show the contract info.
  }
  