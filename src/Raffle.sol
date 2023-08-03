// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

/**
 * @title Sample Raffle contract
 * @author UdeRox
 * @notice This contract is created following Pratric's youtube tutorials.
 */
contract Raffle {
    error Raffle__NotEnoughETHSend();

    uint256 private immutable i_enteranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    event EnteredRaffle(address indexed player);

    constructor(uint256 _enteranceFee, uint256 _interval) {
        i_enteranceFee = _enteranceFee;
        i_interval = _interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        // require((msg.value >= 0.1 ether), "You need to send at least one 0.1ETH");
        if (msg.value <= 0.1 ether) {
            revert Raffle__NotEnoughETHSend();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickAwinner() public {
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
        s_lastTimeStamp = block.timestamp;

        // requestId = COORDINATOR.requestRandomWords(
        //     keyHash,
        //     s_subscriptionId,
        //     requestConfirmations,
        //     callbackGasLimit,
        //     numWords
        // );
    }

    function getEnteranceFee() external view returns (uint256) {
        return i_enteranceFee;
    }
}
