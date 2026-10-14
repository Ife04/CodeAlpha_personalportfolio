// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract PersonalPortfolio {
    struct Deposit {
        uint256 amount;
        address token;
        uint256 unlockedAt;
        bool withdraw;
    }

    mapping(address => Deposit[]) public deposits;
    mapping(address => uint256) public totalDeposits;

    function depositETH(uint256 lockDuration) public payable returns (uint256) {
        require(msg.value > 0, "insufficient funds");
        totalDeposits[msg.sender] += msg.value;
        uint256 unlockedAt = block.timestamp + lockDuration;
        deposits[msg.sender].push(
            Deposit({
                amount: msg.value,
                token: address(0), // ETH
                unlockedAt: unlockedAt,
                withdraw: false
            })
        );
        return msg.value;
    }

    function withdraw(uint256 index) external {
        Deposit storage dep = deposits[msg.sender][index];

        require(index < deposits[msg.sender].length, "invalid index");
        require(block.timestamp >= dep.unlockedAt, "still locked");
        require(dep.withdraw == false, "already withdrawn");

        dep.withdraw = true;
        totalDeposits[msg.sender] -= dep.amount;
        (bool success, ) = msg.sender.call{value: dep.amount}("");
        require(success, "withdraw failed");
    }
}
