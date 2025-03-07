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
contract CuCoBlockchainDevicesTest is CuCoBlockchain {

    CuCoBlockchain cuco;
    /// Define variables referring to different accounts
    address acc0;
    address acc1;
    address acc2;
    address constant device1 = 0xded8187060f601c6CAc55a79D21c53B5Dc788D2d;
    address constant device2 = 0xab470Ce39EDa8A7ED47Fbba1F6a50BB94E6088ab;

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
    function addDeviceNoPermissionsFail() public {
        addDeviceToCustomer(0, device1);
    }

    function addDeviceSuccess() public {
        addDeviceToCustomer(0, device1);
        Assert.equal(customers[0].devices.length, 1, "Devices array should have 1 member");
        Assert.equal(customers[0].devices[0], device1, "Device1 should be in position 0 of devices array");
    }

    function removeDeviceSuccess() public {

    }

    function getAllDevicesSuccess() public {
        createCustomer(0, acc1);
        addDeviceToCustomer(1, device2);
        address[] memory devices = getDevicesUnderCustomer(0);
        Assert.equal(devices.length, 2, "Root customer should have 1 device at this point");
        Assert.equal(devices[0], device1, "The first device should be device1");
        Assert.equal(devices[1], device2, "The second device should be device2");
    }

}