// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ZKEmailUtils} from "@openzeppelin/community-contracts/utils/cryptography/ZKEmailUtils.sol";
import {CommandUtils} from "@zk-email/email-tx-builder/src/libraries/CommandUtils.sol";
import {EmailAuthMsg} from "@zk-email/email-tx-builder/src/interfaces/IEmailTypes.sol";
import {IDKIMRegistry} from "@zk-email/contracts/DKIMRegistry.sol";
import {IVerifier} from "@zk-email/email-tx-builder/src/interfaces/IVerifier.sol";

contract ZKEmailRegistrar {
    using ZKEmailUtils for EmailAuthMsg;

    IVerifier public verifier;
    IDKIMRegistry public dkimregistry;

    error InvalidProof(ZKEmailUtils.EmailProofError error);
    error InvalidAccountSalt();

    constructor(address _verifier, address _dkimregistry) {
        verifier = IVerifier(_verifier);
        dkimregistry = IDKIMRegistry(_dkimregistry);
    }

    /// @notice Allows the owner of an email address to claim the corresponding ENS name for any ethereum address.
    ///         For example, the owner of "myemail[at]example.com" will claim "myemail[at]example.com.email.eth" and
    ///         set 0x1234567890123456789012345678901234567890 as the owner of "myemail[at]example.com.email.eth".
    ///
    ///         The zk-email command for claiming an ENS name is:
    ///         `Claim ENS name for address {ethAddr}`
    ///
    /// @param name The email address that the user is claiming to own, e.g., "myemail@example.com".
    /// @param authMsg The zkemail proof of ownership of the claimed email.
    function proveAndClaim(bytes memory name, EmailAuthMsg memory authMsg) external {
        ZKEmailUtils.EmailProofError result = authMsg.isValidZKEmail(dkimregistry, verifier, _getCommandTemplate());

        if (result != ZKEmailUtils.EmailProofError.NoError) {
            revert InvalidProof(result);
        } else if (
            keccak256(abi.encodePacked("TODO:IMPLEMENT POSEIDON HASH", authMsg.proof.accountSalt))
                != authMsg.proof.accountSalt
        ) {
            revert InvalidAccountSalt();
        }

        // TODO: Implement the logic to claim the ENS name
    }

    function _getCommandTemplate() internal pure returns (string[] memory) {
        string[] memory commandTemplate = new string[](6);
        commandTemplate[0] = "Claim";
        commandTemplate[1] = "ENS";
        commandTemplate[2] = "name";
        commandTemplate[3] = "for";
        commandTemplate[4] = "address";
        commandTemplate[5] = CommandUtils.ETH_ADDR_MATCHER;

        return commandTemplate;
    }
}
