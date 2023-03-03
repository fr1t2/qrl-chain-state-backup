#!/bin/bash

## Notarize.sh
#
# Script Notarizes the state checksum file, uploads the state and files to a 
# digital ocean spaces bucket for serving to the public through the front end 
# hosted at https://qrl.co.in.

# - Add notarization of files using sha256sum from the state bootstrap
# 
# 
# 
# 
# This script requires 
# - Bootstrap node's sha256sum file
# - qrl-cli
# - QRL Address with height of 14

user="fr1t2"
NET_NAME=Testnet
BACKUP_PATH="/home/$user/qrl-chain-state-backup/qrl_bootstrap_files"
QRL_DIR="/home/$user/.qrl-testnet"
QRL_WALLET=wallet.json
BOOTSTRAP_FILE="$BACKUP_PATH/$NET_NAME/QRL_$NET_NAME_State.tar.gz"
STATS_FILE="$BACKUP_PATH/$NET_NAME/QRL_Testnet_Node_Stats.json"
CHECKSUM_FILE="$BACKUP_PATH/$NET_NAME/"$NET_NAME"_State_Checksums.txt"
BOOTSTRAP_LOGS="$BACKUP_PATH/qrl_bootstrap.logs"

echo "[$(date -u)] QRL.CO.IN Notarize Script" |tee -a "$BOOTSTRAP_LOGS"
echo "----------------------------------------------" | tee -a "$BOOTSTRAP_LOGS" 
echo "Notarize checksums for "$NET_NAME" bootstrap to Cloud" | tee -a "$BOOTSTRAP_LOGS"  
echo "----------------------------------------------" | tee -a "$BOOTSTRAP_LOGS"  

# Check for address/wallet and if not found generate
if [[ ! -d "$QRL_DIR" ]]; then
  echo -e "[$(date -u)] QRL Directory Not Found! Should be at: $QRL_DIR/$QRL_WALLET" | tee -a "$BOOTSTRAP_LOGS"
  exit 1
fi

if [[ ! -f "$QRL_DIR"/"$QRL_WALLET" ]]; then
  echo "[$(date -u)] Wallet not found! Generating New Address at $QRL_DIR/$QRL_WALLET" | tee -a "$BOOTSTRAP_LOGS"
  sudo -H -u "$user" qrl-cli create-wallet -f "$QRL_DIR"/"$QRL_WALLET" -h 14 # generate qrl address using the qrl-cli, tree height 14
  wallet_success=$?
  echo "["`date`"] create-wallet exit code: $wallet_success" | tee -a "$BOOTSTRAP_LOGS"
  if [[ "$wallet_success" = "1" ]]; then
    echo "["`date`"] ERROR: generate-wallet failure!" | tee -a "$BOOTSTRAP_LOGS"
    exit 1
  fi
fi

QRL_ADDRESS="$(cat $QRL_DIR/$QRL_WALLET |jq .[0].address | tr -d '"')"
echo "[$(date -u)] QRL Address: $QRL_ADDRESS" |tee -a "$BOOTSTRAP_LOGS"

# Get next OTS
OTS_KEY="$(sudo -H -u $user qrl-cli ots $QRL_ADDRESS -t -j |grep next_key |jq .[0].next_key)"
echo "[$(date -u)] Next unused OTS key: $OTS_KEY" |tee -a "$BOOTSTRAP_LOGS"

# Get shasum of file
SHASUM="$(sha256sum $CHECKSUM_FILE | awk '{print $1}')"
echo "[$(date -u)] sha256sum: $SHASUM" |tee -a "$BOOTSTRAP_LOGS"
echo "[$(date -u)] Notarizing file on-chain" |tee -a "$BOOTSTRAP_LOGS"

# Notarize shasum of checksum file
NOTARIZE="$(sudo -H -u $user qrl-cli notarize $SHASUM -t -M "https://qrl.co.in/chain/ Testnet Checksums" -w $QRL_DIR/$QRL_WALLET -i $OTS_KEY -j )"
echo "[$(date -u)] Notarization complete:" |tee -a "$BOOTSTRAP_LOGS"
# Generate stats file
TXID="$(echo $NOTARIZE |jq .[0].tx_id | tr -d '"')"
echo "[$(date -u)] QRL Transaction ID: $TXID" |tee -a "$BOOTSTRAP_LOGS"
echo "[$(date -u)] Transaction Verification: https://testnet-explorer.theqrl.org/tx/$TXID" |tee -a "$BOOTSTRAP_LOGS"

# Grab the chain state
CHAIN_STATE="$(sudo -H -u $user /home/$user/.local/bin/qrl --json --port_pub 19019 state)"

# remove the old stats file
if [ -f "$STATS_FILE" ]; then
  echo "[$(date -u)] Removing old stats file from: $STATS_FILE" | tee -a "$BOOTSTRAP_LOGS"  
  rm -rf "$STATS_FILE"
fi

echo "[$(date -u)] Writing NEW stats file to: $STATS_FILE" | tee -a "$BOOTSTRAP_LOGS"  
cat << EoF > "$STATS_FILE"
[
    {"info":
        { 
            "blockHeight": "$(echo $CHAIN_STATE |jq .info.blockHeight),"
            "blockLastHash": "$(echo $CHAIN_STATE |jq .info.blockLastHash),"
            "networkId": "$(echo $CHAIN_STATE |jq .info.networkId),"
            "numConnections": "$(echo $CHAIN_STATE |jq .info.numConnections), "
            "numKnownPeers": "$(echo $CHAIN_STATE |jq .info.numKnownPeers), "
            "state": "$(echo $CHAIN_STATE |jq .info.state), "
            "uptime": "$(echo $CHAIN_STATE |jq .info.uptime), "
            "version": "$(echo $CHAIN_STATE |jq .info.version) "
        } 
    },
    {"Unix_Timestamp": "$(date +%s)" },
    {"Uncompressed_Chain_Size": "$(du -hs $BACKUP_PATH/$NET_NAME/state | awk '{print $1}')" },
    {"Tar_FileSize": "$(stat -c%s "$BOOTSTRAP_FILE" | numfmt --to iec)" },
    {"address": "$QRL_ADDRESS", "tx_id": "$TXID", "validation":"https://testnet-explorer.theqrl.org/tx/$TXID"}
]
EoF

echo "[$(date -u)] QRL $NET_NAME Chain StateFile Created" |tee -a "$BOOTSTRAP_LOGS"




# Fin