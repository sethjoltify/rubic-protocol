// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { UpdateScriptBase } from "./utils/UpdateScriptBase.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { FeesFacet, IFeesFacet } from "rubic/Facets/FeesFacet.sol";

contract DeployScript is UpdateScriptBase {
    using stdJson for string;

    function run() public returns (address[] memory facets) {

        address onchainIntegrator = address(0xbD8e73Dc667e8B5a231e525a6d5405c832B61030);
        address crosschainIntegrator = address(0x32f71714709e2a9D411a03638a9aA920499BcB0A);

        vm.startBroadcast(deployerPrivateKey);

        IFeesFacet.IntegratorFeeInfo memory onChainIntegratorInfo;
        onChainIntegratorInfo.isIntegrator = true;
        onChainIntegratorInfo.tokenFee = 3000;
        onChainIntegratorInfo.RubicTokenShare = 500000;
        onChainIntegratorInfo.RubicFixedCryptoShare = 0;
        onChainIntegratorInfo.fixedFeeAmount = 0;
        FeesFacet(diamond).setIntegratorInfo(onchainIntegrator, onChainIntegratorInfo);

        IFeesFacet.IntegratorFeeInfo memory crossChainIntegratorInfo;
        crossChainIntegratorInfo.isIntegrator = true;
        crossChainIntegratorInfo.tokenFee = 6000;
        crossChainIntegratorInfo.RubicTokenShare = 500000;
        crossChainIntegratorInfo.RubicFixedCryptoShare = 0;
        crossChainIntegratorInfo.fixedFeeAmount = 2000000;
        FeesFacet(diamond).setIntegratorInfo(crosschainIntegrator, crossChainIntegratorInfo);

        facets = loupe.facetAddresses();

        vm.stopBroadcast();
    }
}
