// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PlayerObject} from "./Player/Libraries/PlayerObject.sol";
import {PlayerLogic} from "./Player/Libraries/PlayerLogic.sol";
import {PlayerErrors} from "./Player/Libraries/PlayerErrors.sol";

contract Core_Monopoly {
    uint256 public playersCount;
    mapping(uint256 => PlayerObject.Player) private player;
    mapping(address => PlayerObject.Player) private playerMapping;
    mapping(bytes => bool) private alreadyExistingName;
    mapping(address => bool) private alreadyExistingAddress;

    function registerPlayer(
        string memory name
    ) external returns (PlayerObject.Player memory p, uint256 playerId_) {
        // Check if the address already exists
        bool duplicateAddress = PlayerLogic.checkDuplicateAddress(
            alreadyExistingAddress,
            msg.sender
        );
        if (duplicateAddress) {
            revert PlayerErrors.DuplicateAddressError(msg.sender);
        }

        // Check if the name is already taken
        (bool nameTaken, ) = PlayerLogic.checkDuplicateName(
            alreadyExistingName,
            name
        );
        if (nameTaken) {
            revert PlayerErrors.DuplicateUsernameError(bytes(name));
        }

        // Increment players count and register the player
        playersCount += 1;
        (p, playerId_) = PlayerLogic.registerPlayer(
            playersCount,
            msg.sender,
            bytes(name),
            player,
            playerMapping
        );

        // Mark the address and name as already existing
        alreadyExistingAddress[msg.sender] = true;
        alreadyExistingName[bytes(name)] = true; // Store name directly as bytes
    }
}
