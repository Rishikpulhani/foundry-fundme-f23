// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMeScript, WithdrawScript} from "../../script/Interactions.s.sol";
contract FundMeTestIntegration is Test {
    FundMe fundme;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // sets value to 1e17
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundme = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    
    /*function testUserCanFundInteractions1() public{
        FundMeScript fundfundme =  new FundMeScript();
        vm.prank(USER);
        fundfundme.fundFundMe(address(fundme));
        //for testing purpose we created the script broken into 2 different functions
        address funderaddress = fundme.getFunder(0);
        assertEq(funderaddress, USER);
    }*/
    //in this test is failing as vm.prank and vm.braodcast are not compatible so for testing purposes we face to do funding manually
    //and cannot remove vm broadcast as then the transaction will not actually take place 
    function testUserCanFundInteractions() public{
        FundMeScript fundfundme =  new FundMeScript();
        fundfundme.fundFundMe(address(fundme));
        WithdrawScript withdrawfundme = new WithdrawScript();
        withdrawfundme.withdrawFundMe(address(fundme));
        assert(address(fundme).balance == 0);
    }
}
