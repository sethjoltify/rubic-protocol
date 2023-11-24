// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { UpdateScriptBase } from "./utils/UpdateScriptBase.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { DiamondCutFacet, IDiamondCut } from "rubic/Facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet, IDiamondLoupe } from "rubic/Facets/DiamondLoupeFacet.sol";
import { OwnershipFacet } from "rubic/Facets/OwnershipFacet.sol";
import { WithdrawFacet } from "rubic/Facets/WithdrawFacet.sol";
import { DexManagerFacet } from "rubic/Facets/DexManagerFacet.sol";
import { AccessManagerFacet } from "rubic/Facets/AccessManagerFacet.sol";
import { FeesFacet } from "rubic/Facets/FeesFacet.sol";

contract DeployScript is UpdateScriptBase {
    using stdJson for string;

    function run() public returns (address[] memory facets) {
        string memory path = string.concat(
            root,
            "/deployments/",
            network,
            ".",
            fileSuffix,
            "json"
        );
        string memory json = vm.readFile(path);
        address diamondLoupe = json.readAddress(".DiamondLoupeFacet");
        address fees = json.readAddress(".FeesFacet");

        vm.startBroadcast(deployerPrivateKey);

        string memory feesConfigPath = string.concat(
            vm.projectRoot(),
            "/config/fees.json"
        );
        string memory feesConfigJson = vm.readFile(feesConfigPath);
        address feeTreasury = feesConfigJson.readAddress(
            string.concat(".config.", "feeTreasury.", network)
        );
        uint256 maxFixedNativeFee = feesConfigJson.readUint(
            string.concat(".config.", network, ".maxFixedNativeFee")
        );
        uint256 maxRubicTokenFee = feesConfigJson.readUint(
            string.concat(".config", ".maxRubicTokenFee")
        );

        bytes memory initCallData = abi.encodeWithSelector(
            FeesFacet.initialize.selector,
            feeTreasury,
            maxRubicTokenFee,
            maxFixedNativeFee
        );


        cutter.diamondCut(cut, fees, initCallData);

        vm.stopBroadcast();
    }
}
