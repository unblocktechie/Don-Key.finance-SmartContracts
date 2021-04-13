// SPDX-License-Identifier: MIT

pragma solidity ^0.6.9;
import "./Controller.sol";
pragma experimental ABIEncoderV2;

/* DonProxy contract will execute cube added
 * in strartegy contract
 */

contract donProxy is Controller {
    mapping(address => bool) public allowed;

    constructor() public {
        admins[msg.sender] = true;
    }

    /**
     * @dev Open gate of donProxy for particular strategy contract
     *       to execute his cubes
     * @param _toAdd startegy contract address
     */
    function addAllowerd(address _toAdd) external onlyAdmin {
        allowed[_toAdd] = true;
    }

    /**
     * @dev Close gate of donProxy for particular strategy contract
     *       to execute his cubes
     * @param _toSub startegy contract address
     */
    function removeAllowerd(address _toSub) external onlyAdmin {
        allowed[_toSub] = false;
    }

    /**
     * @dev These simple function will execute cube one by one
     * @param _target to's Address
     * @param _data json data of Abicall
     */
    function Simple(address _target, bytes memory _data) public payable {
        require(_target != address(0), "target-invalid");

        require(allowed[_target] == true, "target contract not allowed");

        assembly {
            let succeeded := delegatecall(
                gas(),
                _target,
                add(_data, 0x20),
                mload(_data),
                0,
                0
            )

            switch iszero(succeeded)
                case 1 {
                    // throw if delegatecall failed
                    let size := returndatasize()
                    returndatacopy(0x00, 0x00, size)
                    revert(0x00, size)
                }
        }
    }

    /**
     * @dev These function will execute cube in batch
     * @param _targets to's Address
     * @param _datas json data of Abicall
     */
    function batchSimple(address[] memory _targets, bytes[] memory _datas)
        external
    {
        require(
            _targets.length == _datas.length,
            "Tos and datas length inconsistent"
        );

        for (uint256 i = 0; i < _targets.length; i++) {
            Simple(_targets[i], _datas[i]);
        }
    }
}
