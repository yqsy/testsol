/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() {
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>')
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "chalk often urge amused farm person venue half travel gate twenty people";

module.exports = {
    networks: {
        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*",
            gas: 4500000,
            gasPrice: 10000000000,
        },
        ropsten: {
            provider: function() {
                return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/v3/50a4afb18ee44d649ad9548c1828ca79")
            },
            network_id: 3
        },
    },
};
