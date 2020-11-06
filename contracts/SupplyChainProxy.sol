pragma solidity >=0.6.0 <0.7.0;

import "./SupplyChain.sol";

contract SupplyChainProxy {
  address public real;

  constructor(address _real) public {
    real = _real;
  }

  function addItem_catchError(string memory _name, uint _price) public returns(string memory) {
    try SupplyChain(real).addItem(_name, _price) {
      return "";
    } catch Error(string memory reason) {
      return reason;
    }
  }

  function buyItem_catchError(uint sku) public payable returns(string memory) {
    try SupplyChain(real).buyItem.value(msg.value)(sku) {
      return "";
    } catch Error(string memory reason) {
      return reason;
    }
  }

  function shipItem_catchError(uint sku) public returns(string memory) {
    try SupplyChain(real).shipItem(sku) {
      return "";
    } catch Error(string memory reason) {
      return reason;
    }
  }

  function receiveItem_catchError(uint sku) public returns(string memory) {
    try SupplyChain(real).receiveItem(sku) {
      return "";
    } catch Error(string memory reason) {
      return reason;
    }
  }
}