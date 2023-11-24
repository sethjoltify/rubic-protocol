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
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(dexMgr),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors(
                    "DexManagerFacet",
                    emptyExclude
                )
            })
        );
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
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: fees,
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("FeesFacet", emptyExclude)
            })
        );
        console.log("7");

        cutter.diamondCut(cut, address(0), "");
        facets = loupe.facetAddresses();

        vm.stopBroadcast();
    }
}
