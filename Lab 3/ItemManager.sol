// SPDX-License-Identifier: GPL 3.0
pragma solidity ^0.8.0;

// import other contracts
import "./Ownable.sol";
import "./Item.sol";

// ItemManager inherits Ownable properties
contract ItemManager is Ownable {
    // list of step statusses
    enum SupplyChainSteps{Created, Paid, Delivered}

    struct S_Item {
        Item _item;
        ItemManager.SupplyChainSteps _step;
        string _identifier;
    }

    // item list
    mapping(uint => S_Item) public items;
    uint index;

    event SupplyChainStep(uint _itemIndex, uint _step, address _address);

    // creates and add it into items map
    function createItem(string memory _identifier, uint _priceInWei) public onlyOwner {
        Item item = new Item(this, _priceInWei, index);

        items[index]._item = item;
        items[index]._step = SupplyChainSteps.Created;
        items[index]._identifier = _identifier;

        emit SupplyChainStep(index, uint(items[index]._step), address(item));

        index++;
    }

    // triggers payment to a item in items list and change its step status to paid
    function triggerPayment(uint _index) public payable {
        Item item = items[_index]._item;

        require(address(item) == msg.sender, "Only items are allow to update themselves");
        require(item.priceInWei() == msg.value, "Not fully paid yet");
        require(items[_index]._step == SupplyChainSteps.Created, "Item is further in the supply chain");

        items[_index]._step = SupplyChainSteps.Paid;

        emit SupplyChainStep(_index, uint(items[_index]._step), address(item));
    }

    // triggers delivery to an item and sets its status to delivered
    function triggerDelivery(uint _index) public onlyOwner {
        require(items[_index]._step == SupplyChainSteps.Paid, "Item is further in the supply chain");
        items[_index]._step = SupplyChainSteps.Delivered;

        emit SupplyChainStep(_index, uint(items[_index]._step), address(items[_index]._item));
    }
}