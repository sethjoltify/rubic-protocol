// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/StdJson.sol";
import "forge-std/console.sol";
import { DiamondCutFacet, IDiamondCut } from "rubic/Facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "rubic/Facets/DiamondLoupeFacet.sol";

contract UpdateScriptBase is Script {
    using stdJson for string;

    address internal diamond;
    IDiamondCut.FacetCut[] internal cut;
    DiamondCutFacet internal cutter;
    DiamondLoupeFacet internal loupe;
    uint256 internal deployerPrivateKey;
    string internal root;
    string internal network;
    string internal fileSuffix;

    constructor() {
        deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        
        root = vm.projectRoot();
        network = vm.envString("NETWORK");
        fileSuffix = vm.envString("FILE_SUFFIX");

        string memory path = string.concat(
            root,
            "/deployments/",
            network,
            ".",
            fileSuffix,
            "json"
        );
        string memory json = vm.readFile(path);
        diamond = json.readAddress(".RubicMultiProxy");
        cutter = DiamondCutFacet(diamond);
        loupe = DiamondLoupeFacet(diamond);
    }

    function getSelectors(
        string memory _facetName,
        bytes4[] memory _exclude
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](2);
        // cmd[0] = "../../scripts/contract-selectors.sh";
        // cmd[1] = _facetName;
        // string memory exclude;
        // for (uint256 i; i < _exclude.length; i++) {
        //     exclude = string.concat(exclude, fromCode(_exclude[i]), " ");
        // }
        // // cmd[2] = exclude;
        // console.log("res");
        // console.log("vm:", address(vm));
        // console.log("Incre0");

        // string[] memory inputs = new string[](3);
        // inputs[0] = "echo";
        // inputs[1] = "-n";
        // // ABI encoded "gm", as a hex string
        // inputs[2] = "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002676d000000000000000000000000000000000000000000000000000000000000";

        // bytes memory res1 = vm.ffi(inputs);
        // string memory output = abi.decode(res1, (string));
        // console.log(output);


        // string memory path111 = string.concat(
        //     vm.projectRoot(),
        //     "/scripts/contract-selectors.sh"
        // );
        // console.log("Path : ", path111);
        // cmd[0] = path111;
        cmd[0] = "D:/Dev/Work/Rubic/multi-proxy-rubic/scripts/selector.sh";
        cmd[1] = "";
        console.log("cmd[0] : ", cmd[0]);
        console.log("cmd[1] : ", cmd[1]);
        // console.log("cmd[2] : ", cmd[2]);

        bytes memory res = vm.ffi(cmd);
        console.log("Incre");
        console.logBytes(res);
        console.log("Incre1");
        // selectors = abi.decode(res, (bytes4[]));
        console.log("Incre2");
        // console.logBytes4(selectors[0]);
        console.log("Incre3");
    }

    function toHexDigit(uint8 d) internal pure returns (bytes1) {
        if (0 <= d && d <= 9) {
            return bytes1(uint8(bytes1("0")) + d);
        } else if (10 <= uint8(d) && uint8(d) <= 15) {
            return bytes1(uint8(bytes1("a")) + d - 10);
        }
        revert();
    }

    function fromCode(bytes4 code) public pure returns (string memory) {
        bytes memory result = new bytes(10);
        result[0] = bytes1("0");
        result[1] = bytes1("x");
        for (uint256 i = 0; i < 4; ++i) {
            result[2 * i + 2] = toHexDigit(uint8(code[i]) / 16);
            result[2 * i + 3] = toHexDigit(uint8(code[i]) % 16);
        }
        return string(result);
    }
}
