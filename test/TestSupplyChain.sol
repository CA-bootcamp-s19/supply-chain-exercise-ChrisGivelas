pragma solidity >=0.6.0 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "../contracts/SupplyChainProxy.sol";

contract TestSupplyChain {
    uint public initialBalance = 5 ether;

    SupplyChain sc = SupplyChain(DeployedAddresses.SupplyChain());

    fallback() external payable {}

    function testAddItem() public {
      bool r = sc.addItem("Item1", 1 ether);

      Assert.isTrue(r, "Failed to add item");
    }

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests

    // buyItem

    function testBuyItem_withInsufficientFunds() public {
      string memory result = new SupplyChainProxy(address(sc)).buyItem_catchError.value(0.5 ether)(0);
      Assert.equal(result, "User did not pay enough", "Incorrect error reason");
    }

    function testBuyItem_withSufficientFunds() public {
      (string memory name, uint sku, uint price, uint state, address seller, address buyer) = sc.fetchItem(0);

      Assert.equal(state, 0, "Item state should start at ForSale");
      Assert.equal(buyer, address(0), "Impossible!");

      sc.buyItem.value(1 ether)(0);

      (name, sku, price, state, seller, buyer) = sc.fetchItem(0);

      Assert.equal(state, 1, "Item state did not change to Sold");
      Assert.equal(buyer, address(this), "Item did not go to correct buyer");
    }

    function testBuyItem_notForSale() public {
      string memory result = new SupplyChainProxy(address(sc)).buyItem_catchError.value(0.5 ether)(0);
      Assert.equal(result, "Item not for sale", "Incorrect error reason");
    }

    // shipItem

    function testShipItem_callerIsNotSeller() public {
      string memory result = new SupplyChainProxy(address(sc)).shipItem_catchError(0);
      Assert.equal(result, "Incorrect caller", "Incorrect error reason");
    }

    function testShipItem_itemNotSold() public {
      sc.addItem("Item2", 1 ether);

      string memory result = new SupplyChainProxy(address(sc)).shipItem_catchError(1);
      Assert.equal(result, "Item not sold", "Incorrect error reason");
    }

    // receiveItem

    function testReceiveItem_callerIsNotBuyer() public {
      sc.shipItem(0);

      string memory result = new SupplyChainProxy(address(sc)).receiveItem_catchError(0);
      Assert.equal(result, "Incorrect caller", "Incorrect error reason");
    }

    function testReceiveItem_itemNotShipped() public {
      string memory result = new SupplyChainProxy(address(sc)).receiveItem_catchError(1);
      Assert.equal(result, "Item not shipped", "Incorrect error reason");
    }
}
