// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "../src/Raffle.sol";

contract RaffleTest is Test {
    uint256 constant ENTRANCE_FEE = 0.1 ether;
    uint256 constant INITIAL_WALLET_FEE = 10 ether;
    uint256 constant INTERVAL = 60;
    address USER = makeAddr("user");
    Raffle raffle;

    function setUp() public {
        raffle = new Raffle(ENTRANCE_FEE, INTERVAL);
    }

    function testEnteranceFree() public {
        assertEq(raffle.getEnteranceFee(), ENTRANCE_FEE);
    }

    function testRegisterAddressWithNotEnoughETH() public {
        vm.prank(USER);
        vm.deal(USER, INITIAL_WALLET_FEE);
        raffle.enterRaffle{value: 0.09 ether}();
    }
}
