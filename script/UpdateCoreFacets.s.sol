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
        // address ownership = json.readAddress(".OwnershipFacet");
        // address withdraw = json.readAddress(".WithdrawFacet");
        address dexMgr = json.readAddress(".DexManagerFacet");
        // address accessMgr = json.readAddress(".AccessManagerFacet");
        address fees = json.readAddress(".FeesFacet");

        vm.startBroadcast(deployerPrivateKey);

        bytes4[] memory emptyExclude;

        console.log("1");

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
        console.log("2");

        // Ownership Facet
        // cut.push(
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(ownership),
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: getSelectors("OwnershipFacet", emptyExclude)
        //     })
        // );
        // console.log("3");

        // Withdraw Facet
        // cut.push(
        //     IDiamondCut.FacetCut({
        //         facetAddress: withdraw,
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: getSelectors("WithdrawFacet", emptyExclude)
        //     })
        // );
        // console.log("4");

        // Dex Manager Facet
        // cut.push(
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(0),
        //         action: IDiamondCut.FacetCutAction.Remove,
        //         functionSelectors: getSelectors(
        //             "DexManagerFacet",
        //             emptyExclude
        //         )
        //     })
        // );
        console.log("5");

        // Access Manager Facet
        // cut.push(
        //     IDiamondCut.FacetCut({
        //         facetAddress: accessMgr,
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: getSelectors(
        //             "AccessManagerFacet",
        //             emptyExclude
        //         )
        //     })
        // );
        // console.log("6");

        // Fees Facet
        // cut.push(
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(0),
        //         action: IDiamondCut.FacetCutAction.Remove,
        //         functionSelectors: getSelectors("FeesFacet", emptyExclude)
        //     })
        // );
        console.log("7");

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

        console.log("feeTreasury:", feeTreasury);
        console.log("maxTokenFee:", maxRubicTokenFee);
        console.logBytes4(FeesFacet.initialize.selector);

        bytes memory initCallData = abi.encodeWithSelector(
            FeesFacet.initialize.selector,
            feeTreasury,
            maxRubicTokenFee,
            maxFixedNativeFee
        );

        // cutter.diamondCut(cut, fees, initCallData);
        cutter.diamondCut(cut, address(0), "");
        facets = loupe.facetAddresses();

        console.log(facets[0]);
        console.log(facets[1]);

        vm.stopBroadcast();
    }
}
