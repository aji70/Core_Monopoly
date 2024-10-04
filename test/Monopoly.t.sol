// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Core_Monopoly} from "../src/Monopoly.sol";

contract Core_MonopolyTest is Test {
    Core_Monopoly public monopoly;

    function setUp() public {
        monopoly = new Core_Monopoly();
    }

    function test_RegisterPlayer() public {
        monopoly.registerPlayer("Ajidokwu");
    }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
