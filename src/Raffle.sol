// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title Sample Raffle contract
 * @author UdeRox
 * @notice This contract is created following Pratric's youtube tutorials.
 */
contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughETHSend();
    error Raffle__TransferFailed();
    error Raffle__NotOpened();
    error Raffle__UpKeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers,
        uint256 raffleState
    );

    enum RaffleState {
        OPEN,
        CALCULATING
    }
    uint32 private MIN_WORDS = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint16 private immutable i_minBlockConfirmation;
    uint64 private immutable i_subId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    event EnteredRaffle(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 _i_entranceFee,
        uint256 _interval,
        address _vrfCoordinator,
        bytes32 _gasLane,
        uint16 _minBlockConfirmation,
        uint64 _subId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        i_entranceFee = _i_entranceFee;
        i_interval = _interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        i_gasLane = _gasLane;
        i_minBlockConfirmation = _minBlockConfirmation;
        i_subId = _subId;
        i_callbackGasLimit = _callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value <= i_entranceFee) {
            revert Raffle__NotEnoughETHSend();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__NotOpened();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function checkUpKeep(
        bytes memory /*checkdata*/
    ) public view returns (bool upKeepNeeded, bytes memory /*performDate*/) {
        bool timePassed = (block.timestamp - s_lastTimeStamp >= i_interval);
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upKeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers);
        return (upKeepNeeded, "0x0");
    }

    function peformUpKey(bytes calldata /*performData*/) external {
        (bool upKeepNeeded, ) = checkUpKeep("");
        if (!upKeepNeeded) {
            revert Raffle__UpKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.CALCULATING;
        i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subId,
            i_minBlockConfirmation,
            i_callbackGasLimit,
            MIN_WORDS
        );
    }

    //CEI, Check, Effect, Interaction design pattern to follow in the contracts.
    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomWords
    ) internal override {
        //Checks
        //Effects
        uint256 winnerIndex = randomWords[0] % s_players.length;
        address payable winner = s_players[winnerIndex];
        s_recentWinner = winner;

        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(winner);
        // Interactions
        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    function getEnteranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
