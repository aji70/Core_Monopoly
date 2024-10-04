// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library PlayerObject {
    struct Player {
        address player;
        uint id;
        bytes name;
        uint playersBalance;
        uint playersPosition;
    }
}
