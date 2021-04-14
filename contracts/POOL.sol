//SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;

import "./Controller.sol";
import "./SafeMathUpgradeable.sol";
import "./IBEP20.sol";
import "./Strategy.sol";


/**
*   Farmer will create POOL Contract and later
*   farmer will create/update strategy and assign
*   strategy to POOL.
*/
contract POOL is Controller{

    using SafeMathUpgradeable for uint256;

    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    IBEP20 private BUSDtoken = IBEP20(BUSD);
    IBEP20 token;
    uint256 private totalLiquidity;
    uint256 private totalToken;
    address payable strategy;
    address poolOwner;
    Strategy strategyInstance;
    bool private invested;
    address private farmer;
    address private teamAddress = 0x8345F3AFa13a2ACC4fCd55A173eA21078aD958e8;
    uint16 constant FARMER_REWARD = 5; // 5% of profit
    uint16 constant TEAM_REWARD = 5; // 5% of profit
    mapping (address => bool) public investors;
    mapping (address => uint256) private liquidity;


    constructor ()
        public payable
    {
        admins[msg.sender]=true;
        farmer=msg.sender;
        invested=false;
    }

    /**
     * @dev Get farmer Address of the pool
     */
    function getFarmeraddress()
        external view
        returns (address)
    {
        return farmer;
    }


    /**
     * @dev Get Investor Status of the pool
     * @param _investor Investor address
     */
    function getInvestor(
        address _investor
    )
        external view
        returns (bool)
    {
        return investors[_investor];
    }

    /**
     * @dev update investment status and only been called by pool owner
     * @param _investmentStatus Investment status
     */
    function setInvested(
        bool _investmentStatus
    )
        external
        returns (bool)
    {
        require(
            (admins[msg.sender] == true) || (farmer == msg.sender),
            "POOL: only an appropriate sender can do this"
        );

        invested = _investmentStatus;
        return invested;
    }


    /**
    * @dev Assign/update startegy to POOL
    * @param _newStrategy new startegy address
    */
    function setStrategy(
        address payable _newStrategy
    )
        external
    {
        require(
            _newStrategy != address(0x0),
            'newStrategy should be a valid address');

        strategy = _newStrategy;
        strategyInstance=Strategy(_newStrategy);
    }

    /**
    * @dev return assigned strategy to the pool
    */
    function getStrategy()
        external view
        returns (address)
    {
        return strategy;
    }

    /**
    * @dev return investment status to the pool
    */
    function getInvested()
        public view
        returns (bool)
    {
        return invested;
    }


    /**
    * @dev user can deposit/Invest there Token to the pool
    * @param _BUSDtokens amount of BUSD token to be invested in POOL
    */
    function depositLiquidity(
        uint _BUSDtokens
    )
        external payable
        returns (uint256)
    {
        investors[msg.sender]=true;
        totalToken = totalToken.add(_BUSDtokens);
        liquidity[msg.sender] = liquidity[msg.sender].add(_BUSDtokens);
        require(BUSDtoken.transferFrom(msg.sender, address(this), _BUSDtokens));
        return liquidity[msg.sender];
    }

    /**
     * @dev user can withdraw Invested amount to the POOL
     */
    function withdrawLiquidity()
        external
    {
        require(
            invested == false,
            "pool is invested at the moment"
        );
        investors[msg.sender]=false;
        uint256 BUSDshare = BUSDtoken.balanceOf(address(this)).mul(getRatio(msg.sender));
        uint256 profit = BUSDshare > liquidity[msg.sender] ?
                            BUSDshare - liquidity[msg.sender] :
                            0;

        if (profit > 0)
        {
            /* Share 5% of profit amount to Farmer as farmerReward */
            require(BUSDtoken.transferFrom( address(this), farmer,
                        profit.mul(FARMER_REWARD).div(100)));

            /* Share 5% of profit amount to TEAM as commission */
            require(BUSDtoken.transferFrom( address(this), teamAddress,
                        profit.mul(TEAM_REWARD).div(100)));
        }

        totalToken=totalToken.sub(liquidity[msg.sender]);
        liquidity[msg.sender] = 0;

        require(BUSDtoken.transferFrom( address(this), msg.sender,
                    BUSDshare.sub(profit.mul(FARMER_REWARD + TEAM_REWARD).div(100))));
    }

    /**
    * @dev amount of share in pool
    * @param _user investor address who has invested token in POOL
    */
    function getRatio(
        address _user
    )
        internal view
        returns (uint256 ratio)
    {
        ratio = liquidity[_user].div(totalToken);
    }

    /**
    * @dev transfer all liquid BUSD token to strategy contract for further investment
    */
    function invest()
        external
    {
        require(
            farmer == msg.sender || admins[msg.sender] == true,
            "POOL: only strategy or admin can invest"
        );

        BUSDtoken.transferFrom(address(this),address(strategyInstance),BUSDtoken.balanceOf(address(this)));
        BUSDtoken.approve(address(strategyInstance),BUSDtoken.balanceOf(address(this)));
        strategyInstance.runStrategy();
    }
}
