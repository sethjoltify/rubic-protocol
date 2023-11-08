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

import "hardhat/console.sol";

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
        address ownership = json.readAddress(".OwnershipFacet");
        address withdraw = json.readAddress(".WithdrawFacet");
        address dexMgr = json.readAddress(".DexManagerFacet");
        address accessMgr = json.readAddress(".AccessManagerFacet");
        address fees = json.readAddress(".FeesFacet");

        vm.startBroadcast(deployerPrivateKey);

        bytes4[] memory emptyExclude;

        // Diamond Loupe
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(diamondLoupe),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors(
                    "DiamondLoupeFacet",
                    emptyExclude
                )
            })
        );

        // Ownership Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(ownership),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("OwnershipFacet", emptyExclude)
            })
        );

        // Withdraw Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: withdraw,
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("WithdrawFacet", emptyExclude)
            })
        );

        // Dex Manager Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: dexMgr,
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors(
                    "DexManagerFacet",
                    emptyExclude
                )
            })
        );

        // Access Manager Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: accessMgr,
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors(
                    "AccessManagerFacet",
                    emptyExclude
                )
            })
        );

        // Fees Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: fees,
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("FeesFacet", emptyExclude)
            })
        );

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

        console.logBytes('selector:', FeesFacet.initialize.selector);

        bytes memory initCallData = abi.encodeWithSelector(
            FeesFacet.initialize.selector,
            feeTreasury,
            maxRubicTokenFee,
            maxFixedNativeFee
        );

        cutter.diamondCut(cut, fees, initCallData);
        console.logBytes(initCallData);

        facets = loupe.facetAddresses();

        // console.log("facets addresses:", facets);

        vm.stopBroadcast();
    }
}
