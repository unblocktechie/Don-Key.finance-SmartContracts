const solc = require("solc");
const path = require("path");
const fs = require("fs-extra");

const builPath = path.resolve(__dirname, "..", "build");

const createBuildFolder = () => {
  fs.emptyDirSync(builPath);
};

const contractsFolderPath = path.resolve(__dirname, "..", "contracts");

// const StrategyContract = path.resolve(contractsFolderPath, "Strategy.sol");
// const source = fs.readFileSync(StrategyContract, "utf-8");
// var input = {
//   language: 'Solidity',
//   sources: {
//     'Strategy.sol': {
//       content: source
//     }
//   },
//   settings: {
//     outputSelection: {
//       '*': {
//         '*': ['*']
//       }
//     }
//   }
// };
// console.log(solc.compile(JSON.stringify(input)))

const buildSources = () => {
  const sources = {};
  const contractsFiles = [
    "Strategy.sol",
    "Controller.sol",
    "IBEP20.sol",
    "donProxy.sol",
    "POOL.sol",
    "SafeMathUpgradeable.sol",
  ];

  contractsFiles.forEach((file) => {
    const contractFullPath = path.resolve(contractsFolderPath, file);
    const stats = fs.statSync(contractFullPath);
    if (stats.isDirectory()) {
      return;
    }
    const cont = fs.readFileSync(contractFullPath, "utf8");

    sources[file] = {
      content: cont,
    };
  });

  return sources;
};

const input = {
  language: "Solidity",
  sources: buildSources(),
  settings: {
    outputSelection: {
      "*": {
        "*": ["abi", "evm.bytecode"],
      },
    },
  },
};

const compileContracts = () => {
  const compiled = solc.compile(JSON.stringify(input));
  const compiledContracts = JSON.parse(compiled).contracts;
  console.log("Compiling", JSON.parse(compiled));
  for (let contract in compiledContracts) {
    for (let contractName in compiledContracts[contract]) {
      fs.outputJsonSync(
        path.resolve(builPath, `${contractName}.json`),
        compiledContracts[contract][contractName],
        {
          spaces: 2,
        }
      );
    }
  }
};

(function run() {
  createBuildFolder();
  compileContracts();
})();
