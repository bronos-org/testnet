KEY="pluto"
CHAINID="bronos_1038-1"
MONIKER="universe"
KEYRING="os"
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
# to trace evm
TRACE="--trace"
#TRACE=""

apt install -y jq

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# used to exit on first error (any non-zero exit code)
set -e

# Clear everything of previous installation
rm -rf ~/.bronos*

# Set client config
bronosd config keyring-backend $KEYRING
bronosd config chain-id $CHAINID

# set passwd to current user if necessary
(echo $PASSWD; echo $PASSWD) | passwd

# if $KEY exists it should be deleted
(echo $MNEMONIC; echo $PASSWD ; echo $PASSWD)  | bronosd keys add $KEY --recover --keyring-backend $KEYRING --algo $KEYALGO

# Set moniker and chain-id for Bronos (Moniker can be anything, chain-id must be an integer)
bronosd init $MONIKER --chain-id $CHAINID

# copy genesis file to config
wget -O tmp-genesis.json https://raw.githubusercontent.com/bronos-org/testnet/main/genesis.json; mv tmp-genesis.json ~/.bronosd/config/genesis.json

bronosd tendermint reset-state

# bronosd tx staking create-validator \
#   --amount=1000abro \
#   --pubkey='{"@type":"/cosmos.crypto.ed25519.PubKey","key":"NZJf2TlAteIX+ckRA96h30F42pmJUF9vtsbtCts389g="}' \
#   --moniker="drakula" \
#   --chain-id=bronos_1038-1 \
#   --commission-rate="0.05" \
#   --commission-max-rate="0.10" \
#   --commission-max-change-rate="0.01" \
#   --min-self-delegation="1" \
#   --gas 8000000 \
#   --gas-prices 0.00025abro \
#   --from=bronos1sc9u2mgnfy5626dkpm8k05p0shw0kw3e96qmt0


# Run this to ensure everything worked and that the genesis file is setup correctly
bronosd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
bronosd start --pruning=nothing $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0.0001abro --json-rpc.api eth,txpool,personal,net,debug,web3
