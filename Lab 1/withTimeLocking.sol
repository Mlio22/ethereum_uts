// SPDX-License-Identifier: GPL 3.0
pragma solidity ^0.8.1;

contract SendMoneyExample {
    uint public balanceReceived;
    uint public lockedUntil;

    // receive money from msg.value
    function receiveMoney() public payable {
        balanceReceived += msg.value;
        lockedUntil = block.timestamp + 1 minutes;
    }

    // get current balance of selected account
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    // return all money to current selected account after lockedUntil
    function returnMoney() public {
        if (lockedUntil < block.timestamp) {
            address payable to = payable(msg.sender);
            to.transfer(getBalance());
        }
    }

    // return all money to a specific address after lockedUntil
    function returnMoneyTo(address payable _to) public {
        if (lockedUntil < block.timestamp) {
            _to.transfer(getBalance());
        }
    }
}