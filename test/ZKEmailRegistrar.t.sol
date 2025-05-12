// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ZKEmailRegistrar} from "../src/ZKEmailRegistrar.sol";
import {EmailAuthMsgFixtures, EmailAuthMsg} from "@zk-email/email-tx-builder/test/fixtures/EmailAuthMsgFixtures.sol";
import {Groth16Verifier} from "@zk-email/email-tx-builder/test/fixtures/Groth16Verifier.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Verifier} from "@zk-email/email-tx-builder/src/utils/Verifier.sol";

contract MockDKIMRegistry {
    function isDKIMPublicKeyHashValid(string memory, bytes32) external pure returns (bool) {
        return true;
    }
}

contract ZKEmailRegistrarTest is Test {
    ZKEmailRegistrar public zkEmailRegistrar;

    function setUp() public {
        zkEmailRegistrar = new ZKEmailRegistrar(_deployVerifier(address(this)), address(new MockDKIMRegistry()));
    }

    function test_proveAndClaim_shouldClaimWithValidProof() public {
        // TODO: generate valid proofs for claiming an ENS name or mock the verifier
    }

    // ==== Helpers ====

    function _deployVerifier(address owner) internal returns (address) {
        address verifierProxyAddress;
        Verifier verifierImpl = new Verifier();
        Groth16Verifier groth16Verifier = new Groth16Verifier();
        verifierProxyAddress = address(
            new ERC1967Proxy(
                address(verifierImpl), abi.encodeCall(verifierImpl.initialize, (owner, address(groth16Verifier)))
            )
        );
        return verifierProxyAddress;
    }
}
