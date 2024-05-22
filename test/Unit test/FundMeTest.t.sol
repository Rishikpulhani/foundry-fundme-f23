// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // sets value to 1e17
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        assertEq(fundme.getowner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        assertEq(fundme.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //tells that tha next line must revert
        fundme.fund();
    }

    function testFundUpdateFundedDataStructure() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        uint256 amountfunded = fundme.getAddressToAmountFunded(USER);
        //this works even though no money in testing contract as the test is just a simulation , nothing is actually occuring
        assertEq(amountfunded, SEND_VALUE);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testaddFunderToArrayOfFunders() public funded {
        address funderaddress = fundme.getFunder(0);
        assertEq(funderaddress, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        //since there are functions so we can use modifiers to shorten the code
        vm.expectRevert();
        vm.prank(USER); //can change the order of the 2 vm statements as they refer to next line which has a transaction
        fundme.withdraw();
    }

    function testWithdrawAsASingleFunder() public funded {
        //arrange
        uint256 initialownerbalance = fundme.getowner().balance;
        uint256 initialfundmebalance = address(fundme).balance;
        //act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundme.getowner());
        fundme.withdraw();
        uint256 gasEnd = gasleft();
        //as only in this part there is usage of gas ie. the change of state of blockchian is only in this part
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //tx.gasPrice is builtin function
        console.log(gasUsed);
        //assert
        uint256 finalownerbalance = fundme.getowner().balance;
        uint256 finalfundmebalance = address(fundme).balance;
        assertEq(finalownerbalance, initialownerbalance + initialfundmebalance);
        assertEq(finalfundmebalance, 0);
    }

    function testWithdrawWithMulptipleFunders() public funded {
        uint160 numberoffunders = 10;
        uint160 startindex = 1;
        for (uint160 index = startindex; index < numberoffunders; index++) {
            hoax(address(index), STARTING_BALANCE); //can make an address from a number of uint160 by type casting, makeAddr uses string input
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 initialownerbalance = fundme.getowner().balance;
        uint256 initialfundmebalance = address(fundme).balance;
        //act
        vm.startPrank(fundme.getowner());
        fundme.withdraw();
        vm.stopPrank();
        //assert
        uint256 finalownerbalance = fundme.getowner().balance;
        uint256 finalfundmebalance = address(fundme).balance;
        assertEq(finalownerbalance, initialownerbalance + initialfundmebalance);
        assertEq(finalfundmebalance, 0);
    }

    function testWithdrawWithMulptipleFundersCheaper() public funded {
        uint160 numberoffunders = 10;
        uint160 startindex = 1;
        for (uint160 index = startindex; index < numberoffunders; index++) {
            hoax(address(index), STARTING_BALANCE); //can make an address from a number of uint160 by type casting, makeAddr uses string input
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 initialownerbalance = fundme.getowner().balance;
        uint256 initialfundmebalance = address(fundme).balance;
        //act
        vm.startPrank(fundme.getowner());
        fundme.cheaperWithdraw();
        vm.stopPrank();
        //assert
        uint256 finalownerbalance = fundme.getowner().balance;
        uint256 finalfundmebalance = address(fundme).balance;
        assertEq(finalownerbalance, initialownerbalance + initialfundmebalance);
        assertEq(finalfundmebalance, 0);
    }
}
