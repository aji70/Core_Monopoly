// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Core_Monopoly} from "../src/Monopoly.sol";

contract Core_MonopolyTest is Test {
    Core_Monopoly public monopoly;

    address expectedOwner = address(this);
    address clientA = address(0xa);
    address clientB = address(0xb);
    address inspector1 = address(0xF);
    address clientc = address(0xaa);
    address clientd = address(0xac);
    address cliente = address(0xad);
    address clientf = address(0xaab);
    address vehicleInspector = address(0xAF);

    function setUp() public {
        monopoly = new Core_Monopoly();
    }

    function test_RegisterPlayer() public {
        monopoly.registerPlayer("Ajidokwu");
        vm.prank(clientA);
        monopoly.registerPlayer("Ajiokwu");
        vm.prank(clientB);
        monopoly.registerPlayer("Ajidoku");
        vm.prank(inspector1);
        monopoly.registerPlayer("Aidokwu");
        vm.prank(vehicleInspector);
        monopoly.registerPlayer("jidokwu");
        vm.prank(clientc);
        monopoly.registerPlayer("Ajidokw");
        vm.prank(clientd);
        monopoly.registerPlayer("Ajidou");
        vm.prank(cliente);
        monopoly.registerPlayer("Ajidu");
        vm.prank(clientf);
        vm.expectRevert("Maximum no Of players Allowed is 8");
        monopoly.registerPlayer("Ajidu");
    }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
