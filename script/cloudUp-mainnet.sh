#!/bin/bash

# 
## CloudUp.sh
#
# Script uploads all files to the cloud at Digital Ocean.

## Requires
# - State files bootstrapped using the tools from https://github.com/0xFF0/QRL_bootstrap
# - s3cmd setup for the digital ocean spaces upload
# jq installed
user="fr1t2"
DO_SPACE='qrl-chain' # Digital Ocean Space
DO_BUCKET="mainnet" # Digital Ocean Bucket name
BACKUP_PATH="/home/$user/qrl-chain-state-backup/qrl_bootstrap_files"
NET_NAME=Mainnet
BOOTSTRAP_FILE="$BACKUP_PATH/$NET_NAME/QRL_$NET_NAME_State.tar.gz"
STATS_FILE="$BACKUP_PATH/$NET_NAME/QRL_Node_Stats.json"
CHECKSUM_FILE="$BACKUP_PATH/$NET_NAME/$NET_NAME_State_Checksums.txt"
BOOTSTRAP_LOGS="$BACKUP_PATH/qrl_bootstrap.logs"

echo "----------------------------------------------" | tee -a "$BOOTSTRAP_LOGS" 
echo "Upload QRL $NET_NAME bootstrap to Cloud" | tee -a "$BOOTSTRAP_LOGS"  
echo "----------------------------------------------" | tee -a "$BOOTSTRAP_LOGS"  

# add upload to Digital Ocean spaces here
# upload the tar file
echo "[$(date -u)] Upload Bootstrap TAR file:" |tee -a "$BOOTSTRAP_LOGS"
s3cmd put "$BOOTSTRAP_FILE" s3://"${DO_SPACE}"/"${DO_BUCKET}"/  -P
## upload the stats data
echo "[$(date -u)] Upload Stats JSON file:" |tee -a "$BOOTSTRAP_LOGS"
s3cmd put "$STATS_FILE" s3://"${DO_SPACE}"/"${DO_BUCKET}"/ -P
# Upload the checksum file
echo "[$(date -u)] Upload Bootstrap Checksums file:" |tee -a "$BOOTSTRAP_LOGS"
s3cmd put "$CHECKSUM_FILE" s3://"${DO_SPACE}"/"${DO_BUCKET}"/ -P
echo "[$(date -u)] Upload Bootstrap Checksums file:" |tee -a "$BOOTSTRAP_LOGS"

s3cmd put "$CHECKSUM_FILE" s3://"${DO_SPACE}"/"${DO_BUCKET}"/ -P
echo "[$(date -u)] Upload Complete:" |tee -a "$BOOTSTRAP_LOGS"
