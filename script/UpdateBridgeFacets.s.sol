// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { UpdateScriptBase } from "./utils/UpdateScriptBase.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { DiamondCutFacet, IDiamondCut } from "rubic/Facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet, IDiamondLoupe } from "rubic/Facets/DiamondLoupeFacet.sol";

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
        address xy = json.readAddress(".XYFacet");
        address symbiosis = json.readAddress(".SymbiosisFacet");
        address stargate = json.readAddress(".StargateFacet");
        address multichain = json.readAddress(".MultichainFacet");

        vm.startBroadcast(deployerPrivateKey);

        bytes4[] memory emptyExclude;

        // XY Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(xy),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("XYFacet", emptyExclude)
            })
        );

        // Symbiosis Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(symbiosis),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("SymbiosisFacet", emptyExclude)
            })
        );

        // Stargate Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(stargate),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("StargateFacet", emptyExclude)
            })
        );

        // MultiChain Facet
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(multichain),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: getSelectors("MultichainFacet", emptyExclude)
            })
        );

        cutter.diamondCut(cut, address(0), "");
        facets = loupe.facetAddresses();

        vm.stopBroadcast();
    }
}
