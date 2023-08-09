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
        // HelperConfig  helperConfig = new HelperConfig();
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();
        // () = helperConfig.getSepoliaEthConfig();
        // vm.prank(address(0));
        // raffle = new Raffle(ENTRANCE_FEE, INTERVAL,address(0),3,2,5,20000);
        // raffle = new Raffle(ENTRANCE_FEE, INTERVAL);
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

    function testEmitEvents() public {
        vm.prank(PLAYER);
        vm.deal(PLAYER, PLAYER_BALNCE);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: 0.9 ether}();
    }
}
