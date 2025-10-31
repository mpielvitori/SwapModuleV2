## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Installation

```shell
forge install OpenZeppelin/openzeppelin-contracts
forge install Uniswap/v2-periphery
forge install foundry-rs/forge-std
```

Copy `.env.example` to `.env` and fill in your RPC URL(s).
```shell
cp .env.example .env
```

Load environment variables
```shell
source .env
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil pointing to Sepolia fork

```shell
anvil --fork-url $SEPOLIA_RPC_URL
```

### Import anvil wallets:
```shell
cast wallet import wallet0 --interactive
```

### Deploy SwapModuleV2 contract

```shell
forge script script/SwapModuleV2.s.sol  --rpc-url $RPC_URL --broadcast --account wallet0 --sender $WALLET_ADDRESS
```
Replace `LOCAL_CONTRACT` env variable in .env file to the deployed contract address.
Export variables again:
```shell
source .env
```

### Realizar swap
```shell
cast send $LOCAL_CONTRACT "swapExactEthForTokensSingle(address,uint256,uint256)" $USDC_ADDRESS 0 9999999999 --rpc-url $RPC_URL --value 10000000000000000 --account wallet0 --from $WALLET_ADDRESS
```

### Utils commands:

* Ver dirección de router:
```shell
cast call $LOCAL_CONTRACT "ROUTER()(address)" --rpc-url $RPC_URL
```

* Chequear saldo USDC
```shell
cast call $USDC_ADDRESS "balanceOf(address)(uint256)" $WALLET_ADDRESS --rpc-url $RPC_URL
```

* Chequear saldo ETH
```shell
cast balance $WALLET_ADDRESS --rpc-url $RPC_URL
```

### Deploy Wrapper contract
```shell
forge script script/Wrapper.s.sol  --rpc-url $RPC_URL --broadcast --account wallet0 --sender $WALLET_ADDRESS
```

Replace `WRAPPER_CONTRACT` env variable in .env file to the deployed contract address.
Export variables again:
```shell
source .env
```

### Swap preview
```shell
cast call $WRAPPER_CONTRACT \
  "previewSwapToUsdc(address,uint256)(uint256)" \
  $WETH_ADDRESS 10000000000000000 \
  --rpc-url $RPC_URL
```

### Check allowance
```shell
cast call $WETH_ADDRESS "allowance(address,address)(uint256)" $WALLET_ADDRESS $WRAPPER_CONTRACT --rpc-url $RPC_URL
```

### Approve WETH to Wrapper contract
```shell
cast send $WETH_ADDRESS "approve(address,uint256)" \
  $WRAPPER_CONTRACT 100000000000000000000 \
  --rpc-url $RPC_URL --account wallet0 --from $WALLET_ADDRESS
```

### Swap WETH to USDC via Wrapper contract
```shell
cast send $WRAPPER_CONTRACT \
  "swapToUsdc(address,uint256,uint256,address)" \
  $WETH_ADDRESS 9000000000000 0 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC \
  --rpc-url $RPC_URL --account wallet0 --from $WALLET_ADDRESS
```

##### In case of insufficient funds error, deposit ETH to WETH contract:
```shell
cast send $WETH_ADDRESS "deposit()" \
  --value 10000000000000000 \
  --rpc-url $RPC_URL --account wallet0 --from $WALLET_ADDRESS
```

### Swap USDC to ETH via Wrapper contract
```shell
cast send $USDC_ADDRESS "approve(address,uint256)" \
  $WRAPPER_CONTRACT 100000000000000000000 \
  --rpc-url $RPC_URL --account wallet0 --from $WALLET_ADDRESS

cast send $WRAPPER_CONTRACT "swapToUsdc(address,uint256,uint256,address)" $USDC_ADDRESS 1 9 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC --rpc-url $RPC_URL --account wallet0 --from $WALLET_ADDRESS
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

