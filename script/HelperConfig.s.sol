// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

contract HelperConfig {
    struct NetWorkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callBackGasLimit;
    }

    function getSepoliaEthConfig()
        public
        view
        returns (NetWorkConfig memory config)
    {}
}
