// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";

// import {MockVRFConsumnerBaseV2} from './mock/MockVRFConsumerBaseV2.sol';

contract RaffleTest is Test {
    /**Events */
    event EnteredRaffle(address indexed player);

    uint256 constant ENTRANCE_FEE = 0.1 ether;
    uint256 public constant PLAYER_BALNCE = 10 ether;
    uint256 constant INTERVAL = 60;
    address PLAYER = makeAddr("player");
    Raffle raffle;
    HelperConfig helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callBackGasLimit;

    function setUp() public {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();

        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callBackGasLimit
        ) = helperConfig.activeNetworkConfig();
    }

    // function testEnteranceFree() public {
    // assertEq(raffle.getEnteranceFee(), ENTRANCE_FEE);
    // }

    function testRaffleOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    //Enter raffle with enough ETH
    function testEnterToRaffle() public {
        vm.prank(PLAYER);
        vm.deal(PLAYER, PLAYER_BALNCE);
        raffle.enterRaffle{value: 0.9 ether}();
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
        assert(raffle.getPlayers().length == 1);
        assert(PLAYER == raffle.getPlayers()[0]);
    }

    //Not have enough ETH to join the Raffle
    function testPlayNothaveEnoughETH() public {
        vm.prank(PLAYER);
        vm.deal(PLAYER, PLAYER_BALNCE);
        vm.expectRevert(Raffle.Raffle__NotEnoughETHSend.selector);
        raffle.enterRaffle{value: 0.09 ether}();
        // revert(raffle.getPlayers().length == 0);
    }

    function testPlayerHasEnoguhETHRaffleIsClosed() public {}

    function testEmitEventOnEntrance() public {
        vm.prank(PLAYER);
        vm.deal(PLAYER, PLAYER_BALNCE);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: 0.9 ether}();
    }

    function testCantEnterWhenCalculating() public {
        vm.prank(PLAYER);
        vm.deal(PLAYER, PLAYER_BALNCE);
        raffle.enterRaffle{value: 0.2 ether}();
        vm.warp(block.timestamp + interval +1);
        vm.roll(block.number + 1);
        raffle.peformUpKey("");

        // vm.expectRevert(Raffle.Raffle__NotOpened.selector);
        raffle.enterRaffle{value:entranceFee}();
        vm.prank(PLAYER);
        vm.deal(PLAYER, PLAYER_BALNCE);
        vm.expectRevert();

    }
}
