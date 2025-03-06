// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../CucoBlockchain.sol";
import "hardhat/console.sol";

// Using inheritance in testing is needed to have msg.sender and msg.value work as expected
// When using inheritance, it is not needed to instantiate the contract
contract CuCoBlockchainTest is CuCoBlockchain {

    CuCoBlockchain cuco;
    /// Define variables referring to different accounts
    address acc0;
    address acc1;
    address acc2;

    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
    }

    function checkDeploymentSuccess() public {
        Assert.ok(customers[0].authorizedUsers[acc0], "Deployer should be authorized user of Root customer");
        Assert.equal(owner(), acc0, "Owner should be the deployer");

    }

    function createCustomerSuccess() public {
        createCustomer(0, acc1);
        Assert.ok(customers[1].exists, "Customer does not exist");
        Assert.equal(customers[1].id, 1, "Customer Id should be 1");
        Assert.equal(customers[1].parentId, 0, "Customer parent id should be 0"); 
        Assert.equal(customers[1].authorizedUsers[acc1], true, "acc1 should be authorized user");
        Assert.equal(customers[1].childIds.length, 0,"New customer should start with 0 chidlren");
        Assert.equal(customers[0].childIds[0], 1, "Root customer should have one child");
    }

    function createCustomerFail() public {
        Assert.ok(!(customers[2].exists), "Customer exists but it should not");
    }

    /// #sender: account-0
    function createCustomerOnChildSuccess() public {
        createCustomer(1, acc2);
        console.log("Customer created OK");
        Assert.ok(customers[2].exists, "Customer should exist");
    }

    function checkSuccess() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        Assert.ok(2 == 2, 'should be true');
        Assert.greaterThan(uint(2), uint(1), "2 should be greater than to 1");
        Assert.lesserThan(uint(2), uint(3), "2 should be lesser than to 3");
    }

    function checkSuccess2() public pure returns (bool) {
        // Use the return value (true or false) to test the contract
        return true;
    }
    
    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    function checkSenderAndValue() public payable {
        // account index varies 0-9, value is in wei
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
        Assert.equal(msg.value, 100, "Invalid value");
    }
}
    