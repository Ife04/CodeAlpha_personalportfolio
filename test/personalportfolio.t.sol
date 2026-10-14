// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/personalportfolio.sol";

contract PersonalPortfolioTest is Test {
    PersonalPortfolio public personalPortfolio;

    receive() external payable {
        // This function is required to receive ETH during the test
    }

    function setUp() public {
        personalPortfolio = new PersonalPortfolio();
    }

    function testDepositETH() public {
        uint256 lockDuration = 1 days;
        uint256 depositAmount = 1 ether;

        uint256 returnedAmount = personalPortfolio.depositETH{
            value: depositAmount
        }(lockDuration);
        assertEq(returnedAmount, depositAmount);
    }

    function testWithdraw() public {
        uint256 lockDuration = 1 days;
        uint256 depositAmount = 1 ether;

        personalPortfolio.depositETH{value: depositAmount}(lockDuration);

        // Fast forward time to after the lock duration
        vm.warp(block.timestamp + lockDuration + 1);
        uint256 balanceBefore = address(this).balance;
        personalPortfolio.withdraw(0);

        assertEq(
            address(this).balance,
            balanceBefore + depositAmount,
            "Withdraw failed"
        );

        (, , , bool withdraw) = personalPortfolio.deposits(address(this), 0);
        assertTrue(withdraw, "Withdraw status not updated");
    }

    function testCannotWithdrawEarly() public {
        personalPortfolio.depositETH{value: 1 ether}(1 days);
        vm.expectRevert("still locked");
        personalPortfolio.withdraw(0);
    }
}
