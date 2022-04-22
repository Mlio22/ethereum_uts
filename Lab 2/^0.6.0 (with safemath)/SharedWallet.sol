// SPDX-License-Identifier: GPL 3.0

//! This solidity file won't work!
//! because OpenZeppelin's Ownable.sol requires solidity minimum version of ^0.8.0
pragma solidity ^0.6.1;

// this import will occur error in VSCode, use remix instead
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";

contract Allowance is Ownable {
    using SafeMath for uint;

    /**
        event that emited when the allowance is changed
     */
    event AllowanceChanged(address indexed _forWho, address indexed _byWhom, uint _oldAmount, uint _newAmount);
    mapping(address => uint) public allowance;

    // returns if the sender is the contract owner
    function isOwner() internal view returns(bool) {
        return owner() == msg.sender;
    }

    // set allowance by owner
    function setAllowance(address _who, uint _amount) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }

    /** 
        a modifier that filters if
        - the sender is owner or
        - the sender is a member that have sufficent allowance
    */

    modifier ownerOrAllowed(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount, "You are not allowed");
        _;
    }

    // reduce allowance by owner or member
    function reduceAllowance(address _who, uint _amount) internal ownerOrAllowed(_amount) {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who] - _amount);
        allowance[_who] -= _amount;
    }
}

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