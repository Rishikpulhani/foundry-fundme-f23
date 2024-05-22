// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
//in this step we will be running a script ie. foundry will directly execute commands in our terminal

contract FundMeScript is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostrecentdeployement) public {
        vm.startBroadcast();
        FundMe(payable(mostrecentdeployement)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("funded FundMe with %s", SEND_VALUE);
    }

    function run() public {
        //we mostly fund our recently deployed contract
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentDeployment);
    }
}

contract WithdrawScript is Script {
     function withdrawFundMe(address mostrecentdeployement) public {
        vm.startBroadcast();
        FundMe(payable(mostrecentdeployement)).withdraw();
        vm.stopBroadcast();
    }

    function run() public {
        //we mostly fund our recently deployed contract
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentDeployment);
    }
}
