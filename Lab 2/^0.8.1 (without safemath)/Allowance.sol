// SPDX-License-Identifier: GPL 3.0
pragma solidity ^0.8.1;

// this will accour error in VSCode, use remix instead
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Allowance is Ownable {

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