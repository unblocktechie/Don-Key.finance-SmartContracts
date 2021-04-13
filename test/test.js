const fs = require('fs');
const ERC20Contract = require('erc20-contract-js');
const mnemonic = fs.readFileSync("/Users/yonatanmartsiano/Downloads/by_solidity/byfinance/.secret").toString().trim();
const HDWalletProvider = require('@truffle/hdwallet-provider');
var provider = new HDWalletProvider(mnemonic, `https://bsc-dataseed1.binance.org`);

const Web3 = require('web3');
const { assert } = require('console');
const { cpuUsage } = require('process');
var web3 = new Web3(provider);

let accounts = [];


async function main() {

    var accounts = await web3.eth.getAccounts();
    var WBNBaddress="0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
    var BDOaddress="0x190b589cf9Fb8DDEabBFeae36a813FFb2A702454";
    var CakeLptokenaddress="0xc5b0d73a7c0e4eaf66babf7ee16a2096447f7ad6";
    var BUSDaddress = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";


    var ShareRewardPooladdress = "0x948dB1713D4392EC04C86189070557C5A8566766" ;
    var poolAddress = "0x921E8B9185Fe180Eb2a1770A1137F6e6E22E9B37";
    var pancakeInterfaceAddress="0x6043aaE4F36249AD130e4dB4BbB772B45C7c9834";
    // var strategyAddress = "0x57Eb2647f9E54A1E1259D6428a0edb371BF714D8";
    var strategyAddress = "0xDB94380Ec6ad653e41BaBBb1cE19f4d41B58b028";
    var byProxyaddress="0x66b36107347ec36bbB9B622A9934A5cAb60fef3a";
    var PancakeRouteraddress="0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F";
    const BUSD = new ERC20Contract(web3, BUSDaddress);
    const WBNB = new ERC20Contract(web3, WBNBaddress);
    const BDO = new ERC20Contract(web3, BDOaddress);
    const CakeLptoken= new ERC20Contract(web3, CakeLptokenaddress);


    var poolabiSrc = fs.readFileSync('/Users/yonatanmartsiano/Downloads/by_solidity/byfinance/build/contracts/POOL.json', 'utf8');
    var byProxyabiSrc = fs.readFileSync('/Users/yonatanmartsiano/Downloads/by_solidity/byfinance/build/contracts/byProxy.json', 'utf8');
   var pancakeInterfaceAbiSrc = fs.readFileSync('/Users/yonatanmartsiano/Downloads/by_solidity/byfinance/build/contracts/PancakeInterface.json', 'utf8');
      var PancakeRouterAbiSrc = fs.readFileSync('/Users/yonatanmartsiano/Downloads/by_solidity/byfinance/build/contracts/PancakeRouter.json', 'utf8');
      var ShareRewardPoolAbiSrc=fs.readFileSync("/Users/yonatanmartsiano/Downloads/by_solidity/byfinance/build/contracts/ShareRewardPool.json");
      var StrategyAbiSrc=fs.readFileSync("/Users/yonatanmartsiano/Downloads/by_solidity/byfinance/build/contracts/Strategy.json");


    var poolAbiparsed = JSON.parse(poolabiSrc);
    var pancakeInterfaceAbiparsed = JSON.parse(pancakeInterfaceAbiSrc);
    var byProxyAbiparsed = JSON.parse(byProxyabiSrc);
    var PancakeRouterAbiparsed = JSON.parse(PancakeRouterAbiSrc);
    var ShareRewardPoolAbiparsed = JSON.parse(ShareRewardPoolAbiSrc);
    var StrategyAbiparsed = JSON.parse(StrategyAbiSrc);



    var pancakeInterface = new web3.eth.Contract(pancakeInterfaceAbiparsed.abi, pancakeInterfaceAddress);
    var pool = new web3.eth.Contract(poolAbiparsed.abi, poolAddress);
    var byProxy = new web3.eth.Contract(byProxyAbiparsed.abi, byProxyaddress);
    var PancakeRouter = new web3.eth.Contract(PancakeRouterAbiparsed.abi, PancakeRouteraddress);
    var ShareRewardPool = new web3.eth.Contract(ShareRewardPoolAbiparsed.abi, ShareRewardPooladdress);
    var Strategy = new web3.eth.Contract(StrategyAbiparsed.abi, strategyAddress);

    //var strategy = new web3.eth.Contract(strategyParsed.abi, strategyAddress);
    var wbnbAmount = web3.utils.toWei('0.000001');

    // // //approve pool to spend WBNB
    //var wbnbapproval = await WBNB.approve(pancakeInterfaceAddress, wbnbAmount).send({ from: accounts[0] });


    //var wbnbtransfer = await WBNB.transferFrom(accounts[0],poolAddress,wbnbAmount).send({ from: accounts[0] });

   // var init = await pool.methods.initTest().send({ from: accounts[0] });

      //var executePool = await DemoContract.methods.ExecutePOOL().send({ from: accounts[0] }).then(console.log);



    var blockNumber = await web3.eth.getBlockNumber();
    var blockData = await web3.eth.getBlock(blockNumber);
        console.log(blockData.timestamp);


    var datas1= PancakeRouter.methods.swapExactTokensForTokens(wbnbAmount-1,0,[WBNBaddress,BDOaddress],poolAddress,blockData.timestamp+10000).encodeABI();
    var datas2= PancakeRouter.methods.swapExactTokensForTokens(wbnbAmount-1,0,[WBNBaddress,BUSDaddress],poolAddress,blockData.timestamp+10000).encodeABI();
    var first = await pancakeInterface.methods.getEstimatedTOKENBforTOKENA(wbnbAmount,WBNBaddress,BDOaddress).call();
    var second = await pancakeInterface.methods.getEstimatedTOKENBforTOKENA(wbnbAmount,WBNBaddress,BUSDaddress).call();
    var x=0;


    //functions to connect to UI:


    // var add = await Strategy.methods.addCube(PancakeRouteraddress,datas1).send({ from: accounts[0] });

    //  var datas1= PancakeRouter.methods.swapExactTokensForTokens(wbnbAmount-1,0,[WBNBaddress,BDOaddress],poolAddress,blockData.timestamp+10000).encodeABI();

   var addCubes = await Strategy.methods.addCubes([PancakeRouteraddress,PancakeRouteraddress],[datas1,datas1]).send({ from: accounts[0] });

    //var length = await Strategy.methods.getLength().call();
    //console.log(length);

    //var clear = await Strategy.methods.removeCubes(length).send({ from: accounts[0] });
    //console.log(clear);
    
   var run = await pool.methods.InvestTransfer().send({ from: accounts[0] });
   // console.log(run);




     // var approvalWBNB = await WBNB.approve(byProxyaddress, 2*wbnbAmount).send({ from: accounts[0] });
     // var approvalBUSD = await BUSD.approve(byProxyaddress, second[1]).send({ from: accounts[0] });
      //var approvalBDO = await BDO.approve(byProxyaddress, first[1]).send({ from: accounts[0] });
      //var datas5 =CakeLptoken.approve(byProxyaddress,web3.utils.toWei('0.000001')).send({ from: accounts[0] });

    
    if (x==1){

      var datas5 =CakeLptoken.approve(byProxyaddress,web3.utils.toWei('0.000001')).send({ from: accounts[0] });
      var datas5 =CakeLptoken.approve(ShareRewardPooladdress,web3.utils.toWei('0.000001')).send({ from: accounts[0] });

    };


    //console.log(first[1]);
    //console.log(second[1]);

    var datas3 = pancakeInterface.methods.addPancakeliquidityKEEP(BDOaddress,BUSDaddress,10000,10000).encodeABI();
    var datas4 = PancakeRouter.methods.addLiquidity(BDOaddress,BUSDaddress,first[1],second[1],0,0,accounts[0],blockData.timestamp+10000).encodeABI();
    var datas5 =CakeLptoken.approve(ShareRewardPooladdress,web3.utils.toWei('0.000001')).encodeABI();
    var datas6 =ShareRewardPool.methods.deposit(0,1000).encodeABI();
    console.log(datas1);
    console.log(datas2);


   //var delegatedatas1 = await byProxy.methods.batchSimple([address_1,address_2],[datas1,datas2]).send({from:accounts[0], gas:4000000});
    //var delegatedatas1 =ShareRewardPool.methods.deposit(0,web3.utils.toWei('0.000001')).send({ from: accounts[0] });
    //console.log(await delegatedatas1);


}

main().then(r => {
    console.log(r);
})





