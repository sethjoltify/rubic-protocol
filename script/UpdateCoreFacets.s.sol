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
        address genericCrossSwap = json.readAddress(".GenericCrossChainFacet");
        address genericSwap = json.readAddress(".GenericSwapFacet");
        address peripheryRegistry = json.readAddress(".PeripheryRegistryFacet");
        address transfer = json.readAddress(".TransferFacet");
        address xy = json.readAddress(".XYFacet");
        address symbiosis = json.readAddress(".SymbiosisFacet");
        address stargate = json.readAddress(".StargateFacet");
        address multichain = json.readAddress(".MultichainFacet");
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
                facetAddress: address(dexMgr),
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

        // GenericCrossChain Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(genericCrossSwap),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors(
                    "GenericCrossChainFacet",
                    exclude
                )
            })
        );

        // GenericSwap Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(genericSwap),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors(
                    "GenericSwapFacet",
                    exclude
                )
            })
        );

        // PeripheryRegistry Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(peripheryRegistry),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("PeripheryRegistryFacet", exclude)
            })
        );

        // Transfer Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(transfer),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("TransferFacet", exclude)
            })
        );

        // XY Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(xy),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("XYFacet", exclude)
            })
        );

        // Symbiosis Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(symbiosis),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("SymbiosisFacet", exclude)
            })
        );

        // Stargate Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(stargate),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("StargateFacet", exclude)
            })
        );

        // MultiChain Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(multichain),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("MultichainFacet", exclude)
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

        cutter.diamondCut(cut, address(0), "");
        facets = loupe.facetAddresses();

        vm.stopBroadcast();
    }
}
