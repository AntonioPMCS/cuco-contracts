// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CuCoBlockchain is Ownable {
    
    struct Customer {
        uint256 id;
        uint256 parentId;
        uint256[] childIds;
        address[] devices;
        mapping(address => bool) authorizedUsers;  // Users with control over this customer
        bool exists;
    }

    mapping(uint256 => Customer) public customers;
    uint256 public customerCount = 0;

    event CustomerCreated(uint256 customerId, uint256 parentId);
    event DeviceAdded(uint256 customerId, address device);
    event UserAdded(uint256 customerId, address user);

     /**
     * Check if a user has access to a given customer or any of its parent customers.
     */
    modifier onlyAncestorAdmin (address user, uint256 customerId ) {
         require(_hasAccess(msg.sender, customerId), "Unauthorized: Only ancestor admins can create customers");
        _;
    }

    constructor() Ownable(msg.sender) {
        // Create Root customer
        customers[0].id = customerCount;
        customers[0].parentId = 0;
        customers[0].exists = true;
        customers[0].authorizedUsers[msg.sender] = true;
        emit CustomerCreated(customerCount, 0);
        emit UserAdded(customerCount, msg.sender);
    }

    /**
     * Create a new customer under a parent customer and assign an initial admin user.
     */
    function createCustomer(uint256 parentId, address adminUser) public onlyAncestorAdmin(msg.sender, parentId) returns (uint256) {
        require(customers[parentId].exists, "Parent customer does not exist");

        customerCount++;
        customers[customerCount].id = customerCount;
        customers[customerCount].parentId = parentId;
        customers[customerCount].exists = true;
        customers[customerCount].authorizedUsers[adminUser] = true;

        customers[parentId].childIds.push(customerCount);

        emit CustomerCreated(customerCount, parentId);
        emit UserAdded(customerCount, adminUser);
        return customerCount;
    }

    /**
     * Assign a user to a customer.
     */

    function addUserToCustomer(uint256 customerId, address user) public onlyAncestorAdmin(msg.sender, customerId) {
        require(customers[customerId].exists, "Customer does not exist");

        customers[customerId].authorizedUsers[user] = true;
        emit UserAdded(customerId, user);
    }

    /**
     * Assign a device to a customer.
     */
    function addDeviceToCustomer(uint256 customerId, address device) onlyAncestorAdmin(msg.sender, customerId) public {
        require(customers[customerId].exists, "Customer does not exist");

        customers[customerId].devices.push(device);
        emit DeviceAdded(customerId, device);
    }

    /**
     * Get all devices managed by a customer (including child customers).
     */
    function getDevicesUnderCustomer(uint256 customerId) onlyAncestorAdmin(msg.sender, customerId) public view returns (address[] memory) {
        require(customers[customerId].exists, "Customer does not exist");

        return _gatherDevices(customerId);
    }

    /**
     * Recursively gathers all devices from customer and child customers.
     */
    function _gatherDevices(uint256 customerId) internal view returns (address[] memory) {
        uint256 totalDevices = _countDevices(customerId);
        address[] memory result = new address[](totalDevices);
        uint256 index = 0;

        return _collectDevices(customerId, result, index);
    }

    function _countDevices(uint256 customerId) internal view returns (uint256 count) {
        count += customers[customerId].devices.length;

        for (uint256 i = 0; i < customers[customerId].childIds.length; i++) {
            count += _countDevices(customers[customerId].childIds[i]);
        }
    }

    function _collectDevices(uint256 customerId, address[] memory result, uint256 index) internal view returns (address[] memory) {
        for (uint256 i = 0; i < customers[customerId].devices.length; i++) {
            result[index++] = customers[customerId].devices[i];
        }

        for (uint256 i = 0; i < customers[customerId].childIds.length; i++) {
            result = _collectDevices(customers[customerId].childIds[i], result, index);
        }

        return result;
    }


    /**
    * Modifier helper function to check if a user has access to any ancestor.
    */
    function _hasAccess(address user, uint256 customerId) internal view returns (bool) {
        while (customerId != 0) {
            if (customers[customerId].authorizedUsers[user]) {
                return true;
            }
            customerId = customers[customerId].parentId; // Move up the hierarchy
        }
        if (customers[customerId].authorizedUsers[user]) return true;
        return false;
    }

}