// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract AccessControl {
    mapping(address => bool) public admins;
    mapping(address => bool) public supporters;
    mapping(address => bool) public members;

    event RoleAssigned(address indexed account, string role);

    constructor() {
        admins[msg.sender] = true;
        emit RoleAssigned(msg.sender, "Admin");
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "You are not an admin and cannot call this function!");
        _;
    }

    function assignAdminRole(address account) public onlyAdmin {
        admins[account] = true;
        emit RoleAssigned(account, "Admin");
    }

    function assignOtherRole(address account, string memory role) public onlyAdmin {
        if (keccak256(bytes(role)) == keccak256("Supporter")) {
            supporters[account] = true;
        } else if (keccak256(bytes(role)) == keccak256("Member")) {
            members[account] = true;
        } else {
            revert("Invalid role. Please try again!");
        }

        emit RoleAssigned(account, role);
    }
}