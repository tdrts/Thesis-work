const hre = require("hardhat");
require("dotenv").config();

async function main() {
    const CONTRACT_NAME = process.env.CONTRACT_NAME;
    const CONTRACT_SYMBOL = process.env.CONTRACT_SYMBOL;
    const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

    await hre.run("verify:verify", {
        address: CONTRACT_ADDRESS,
        constructorArguments: [CONTRACT_NAME, CONTRACT_SYMBOL]
    });

    let msg = CONTRACT_NAME + ' (' + CONTRACT_SYMBOL + ') verified at: ';
    console.log(msg, CONTRACT_ADDRESS);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });