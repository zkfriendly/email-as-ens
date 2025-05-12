// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ZKEmailUtils} from "@openzeppelin/community-contracts/utils/cryptography/ZKEmailUtils.sol";
import {EmailAuthMsg} from "@zk-email/email-tx-builder/src/interfaces/IEmailTypes.sol";
import {IDKIMRegistry} from "@zk-email/contracts/DKIMRegistry.sol";
import {IVerifier} from "@zk-email/email-tx-builder/src/interfaces/IVerifier.sol";

contract ZKEmailRegistrar {
    using ZKEmailUtils for EmailAuthMsg;

    IVerifier public verifier;
    IDKIMRegistry public dkimregistry;

    error InvalidProof(ZKEmailUtils.EmailProofError error);

    constructor(address _verifier, address _dkimregistry) {
        verifier = IVerifier(_verifier);
        dkimregistry = IDKIMRegistry(_dkimregistry);
    }

    /// @notice Allows the owner of an email address to claim the corresponding ENS name.
    ///         For example, the owner of "myemail[at]example.com" will claim "myemail[at]example.com.email.eth".
    ///
    /// @param name The email address that the user is claiming to own, e.g., "myemail@example.com".
    /// @param authMsg The zkemail proof of ownership of the claimed email.
    function proveAndClaim(bytes memory name, EmailAuthMsg memory authMsg) public {
        ZKEmailUtils.EmailProofError result = authMsg.isValidZKEmail(dkimregistry, verifier);

        if (result != ZKEmailUtils.EmailProofError.NoError) {
            revert InvalidProof(result);
        }
    }
}
