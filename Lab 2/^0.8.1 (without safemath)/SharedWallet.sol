// SPDX-License-Identifier: GPL 3.0
pragma solidity ^0.8.1;

import "./Allowance.sol";

// SharedWallet inherits Allowance contract
contract SharedWallet is Allowance {
    // events the emits when money sent and received
    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);

    // withdraw member's allowance by owner or member
    // and transfers it to an address
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "Contract doesn't own enough money");

        if(!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }

    // renouncing ownership was available from OpenZeppelin's Ownable.sol
    // which is not allowed in this smart contract
    // so renounceOwnership() is overrided to throw error
    function renounceOwnerShip() public override onlyOwner{
      revert("Can't renounce ownership");
    }


    receive() external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
}