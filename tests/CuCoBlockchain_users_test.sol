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
contract CuCoBlockchainUsersTest is CuCoBlockchain {

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
        Assert.ok(customers[0].exists, "Root customer wasn't created");
        Assert.ok(customers[0].authorizedUsers[acc0], "Deployer should be authorized user of Root customer");
        Assert.equal(owner(), acc0, "Owner should be the deployer");
    }

    /// #sender: account-1
    //  This test will fail with reverted. Remix does not support testing for revert while using msg.sender
    //  For more info check: https://medium.com/coinmonks/solidity-unit-testing-with-remix-ide-a-few-missing-pieces-6677786735d4
    function addUserNoPermissionsFail() public {
        addUserToCustomer(0, acc1);
    }


    function addUserSuccess() public {
        addUserToCustomer(0, acc1);
        Assert.ok(customers[0].authorizedUsers[acc1], "User should be in authorized list");
    }

    function removeUserSuccess() public {
        removeUserFromCustomer(0, acc1);
        Assert.ok(!(customers[0].authorizedUsers[acc1]), "User should not be in authorized list");
    }

    /// #sender: account-1
    // Should revert with unauthorized access
    function addedUserCreatesCustomerFail() public {
        createCustomer(0, acc1);
    }

    /// #sender: account-0
    function addedUserCreatesCustomerSuccess() public {
        createCustomer(0, acc1);
        Assert.ok(customers[1].exists, "Customer created by new user should exist");
    }

    function addUserChildSuccess() public {
        addUserToCustomer(1, acc2);
        Assert.ok(customers[1].authorizedUsers[acc2], "User should be in authorized list");
    }


}