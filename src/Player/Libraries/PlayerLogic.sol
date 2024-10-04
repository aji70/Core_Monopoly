// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PlayerObject} from "./PlayerObject.sol";

library PlayerLogic {
    function registerPlayer(
        uint256 playerCount,
        address playerAddress,
        bytes memory playerName,
        mapping(uint256 => PlayerObject.Player) storage _player,
        mapping(address => PlayerObject.Player) storage playerMapping
    ) internal returns (PlayerObject.Player memory, uint) {
        PlayerObject.Player memory player;
        player.id = playerCount;
        player.player = playerAddress;
        player.name = bytes(playerName);

        playerMapping[msg.sender] = player;
        _player[playerCount] = player;

        return (player, playerCount);
    }

    function checkDuplicateAddress(
        mapping(address => bool) storage existingAddress,
        address playersAddress
    ) internal view returns (bool result) {
        return existingAddress[playersAddress];
    }

    function checkDuplicateName(
        mapping(bytes => bool) storage existingName,
        string memory name
    ) internal view returns (bool result, bytes memory) {
        bytes memory convertedName = convertToLowerCase(name);
        return (result = existingName[convertedName], convertedName);
    }

    function convertToLowerCase(
        string memory input
    ) private pure returns (bytes memory result) {
        bytes memory stringBytes = bytes(input);
        bytes memory lowerCaseBytes = new bytes(stringBytes.length);
        for (uint256 i = 0; i < stringBytes.length; i++) {
            // Convert to lowercase if character is uppercase
            if (stringBytes[i] >= 0x41 && stringBytes[i] <= 0x5A) {
                lowerCaseBytes[i] = bytes1(uint8(stringBytes[i]) + 32);
            } else {
                lowerCaseBytes[i] = stringBytes[i];
            }
        }
        result = lowerCaseBytes;
    }
}
