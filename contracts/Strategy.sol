// SPDX-License-Identifier: MIT

pragma solidity ^0.6.9;

import "./donProxy.sol";
import "./Controller.sol";
pragma experimental ABIEncoderV2;


/**
 * @dev Farmer will create strategy and add multiple cubes
 *      to strategy, base on cubes further investment will be done.
 */
contract Strategy is Controller{
    address[] private tos;
    bytes[] private datas;
    string private name;
    donProxy donProxyInstance;
    address poolAddress;
    address payable donProxyaddress = 0x139f3766B572f907A400806944c84F66155e5673;
    bool locked;

    constructor(
        string memory _name
    ) 
        public
    {
        name = _name;
        donProxyInstance = donProxy(donProxyaddress);
        locked = false;
    }

    /**
     * @dev add new multiple cubes to strategy, base on cubes further 
     *      investment will be done.
     * @param _newTos address of tos
     * @param _newDatas json data of abicall
     */
    function addCubes(
        address[] memory _newTos,
        bytes[] memory _newDatas
    ) 
        external
    {
        require(
            locked == false,
            "Strategy is locked and cannot be changes"
        );

        require(
            _newTos.length == _newDatas.length,
            "Tos and datas length inconsistent"
        );

        for (uint256 i = 0; i < _newTos.length; i++)
        {
            tos.push(_newTos[i]);
            datas.push(_newDatas[i]);    
        }

        locked=true;
    }

    /**
     * @dev get array of Tos list
     */
    function getTos()
        external view
        returns(address[] memory)
    {
        return tos;
    }
    
    /**
     * @dev get array of Json rpc data list
     */
    function getDatas()
        external view
        returns(bytes[] memory)
    {
        return datas;
    }
    
    /**
     * @dev get particuler To from the list
     * @param _cubeNumber cube index
     */
    function getTo(
        uint _cubeNumber
    )
        external view
        returns(address)
    {
        return tos[_cubeNumber];
    }
    
    /**
     * @dev get particuler DATA from the list
     * @param _cubeNumber cube index
     */
    function getData(
        uint _cubeNumber
    )
        external view
        returns(bytes memory)
    {
        return datas[_cubeNumber];
    }
    
    /**
     * @dev get Name of strategy
     */
    function getName()
        external view
        returns(string memory)
    {
        return name;
    }
        
    /**
     * @dev Lock strategy, so no further cubes will added or removed
     */ 
    function lockStrategy() 
        external
    {
        require( 
            locked==false,
            "Strategy is locked and cannot be changes"
        );

        locked=true;
    }
    
    /**
     * @dev Get strategy is lock status
     */
    function getLocked() 
        external view
        returns (bool)
    {
        return locked;
    }

    /**
     * @dev Get strategy Cube length.
     */ 
    function getLength() 
        external view
        returns (uint)
    {
        return tos.length;   
    }

    /**
     * @dev Get POOL addres to be strategy is linked.
     */ 
    function getPool() 
        external view
        returns (address)
    {
        return poolAddress;        
    }
    
    /**
     * @dev Set POOL address to which strategy is going to be linked.
     * @param _newPool POOL Address
     */ 
    function setPool(
        address _newPool
    ) 
        external
    {
        poolAddress = _newPool;
    }

    /**
     * @dev These function will called by POOL contract, which will run strategy
     *      based on cubes added to strategy.
     */ 
    function runStrategy()
        external payable 
    {
        donProxyInstance.batchSimple(tos,datas);
    }
    
    /**
     * @dev These function will approve donProxyaddress contract to invested
     *      on his behalf
     * @param _tokenAddress BEP-20 token address
     */ 
    function approveToken(
        address _tokenAddress
    ) 
        external payable
    {
        IBEP20 token = IBEP20(_tokenAddress);
        token.approve(donProxyaddress,token.balanceOf(address(this)));
    }

    /**
     * @dev These function will transfer all token back to POOL contract
     * @param _tokenAddress BEP-20 token address
     */ 
    function transferPool(
        address payable _tokenAddress
    ) 
        external
    {
        IBEP20 token = IBEP20(_tokenAddress);
        token.transferFrom(address(this),poolAddress,token.balanceOf(address(this)));
    }

    /**
     * @dev Get token amount available with strategy contract
     * @param _tokenAddress BEP-20 token address
     */ 
    function getToken(
        address payable _tokenAddress
    ) 
        external view 
        returns(uint256)
    {
        IBEP20 token = IBEP20(_tokenAddress);
        return token.balanceOf(address(this));
    }

   /**
     * @dev set donProxy contract address
     * @param _newProxy Don proxy contract address
     */ 
    function setProxy(
        address payable _newProxy
    ) 
        external payable
    {
        donProxyaddress = _newProxy;
        donProxyInstance=donProxy(_newProxy);
    }   
}