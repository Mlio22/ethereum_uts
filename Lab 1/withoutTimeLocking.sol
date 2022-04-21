// SPDX-License-Identifier: GPL 3.0
pragma solidity ^0.8.1;

contract SendMoneyExample {
    uint public balanceReceived;

    // receive money from msg.value
    function receiveMoney() public payable {
        balanceReceived += msg.value;
    }

    // get current balance of selected account
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    // return all money to current selected account
    function returnMoney() public {
        address payable to = payable(msg.sender);
        to.transfer(getBalance());
    }

    // return all money to a specific address
    function returnMoneyTo(address payable _to) public {
        _to.transfer(getBalance());
    }
}