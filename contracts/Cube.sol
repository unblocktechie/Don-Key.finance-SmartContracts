//SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;
import "./IBEP20.sol";

abstract contract Cube {
    mapping(address => bool) public admins;

    receive() external payable {}

    constructor() public {
        admins[msg.sender] = true;
    }

    modifier onlyAdmin {
        require(admins[msg.sender] == true, "Only admin can do that");
        _;
    }

    function addAdmin(address _admin) public onlyAdmin {
        admins[_admin] = true;
    }

    function checkadmin(address _check) public view returns (bool) {
        return admins[_check];
    }
}
