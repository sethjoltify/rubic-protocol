// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { DeployScriptBase } from "./utils/DeployScriptBase.sol";
import { AccessManagerFacet } from "rubic/Facets/AccessManagerFacet.sol";

import "hardhat/console.sol";

contract DeployScript is DeployScriptBase {
    constructor() DeployScriptBase("AccessManagerFacet") {}

    function run() public returns (AccessManagerFacet deployed) {
        vm.startBroadcast(deployerPrivateKey);

        if (isDeployed()) {
            return AccessManagerFacet(predicted);
        }

        if (networkSupportsCreate3(network)) {
            deployed = AccessManagerFacet(
                factory.deploy(salt, type(AccessManagerFacet).creationCode)
            );
        } else {
            deployed = new AccessManagerFacet();
        }
        vm.stopBroadcast();
    }
}
