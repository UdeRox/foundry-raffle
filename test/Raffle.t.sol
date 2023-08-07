// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "../src/Raffle.sol";
// import {MockVRFConsumnerBaseV2} from './mock/MockVRFConsumerBaseV2.sol';

contract RaffleTest is Test {
    uint256 constant ENTRANCE_FEE = 0.1 ether;
    uint256 constant INITIAL_WALLET_FEE = 10 ether;
    uint256 constant INTERVAL = 60;
    address USER = makeAddr("user");
    Raffle raffle;

    // constructor(
    //     uint256 _i_entranceFee,
    //     uint256 _interval,
    //     address _vrfCoordinator,
    //     bytes32 _gasLane,
    //     uint16 _minBlockConfirmation,
    //     uint64 _subId,
    //     uint32 _callbackGasLimit
    // ) 
    function setUp() public {
        vm.prank(address(0));
        // raffle = new Raffle(ENTRANCE_FEE, INTERVAL,address(0),3,2,5,20000);
        // raffle = new Raffle(ENTRANCE_FEE, INTERVAL);
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
