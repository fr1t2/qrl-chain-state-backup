#!/bin/bash

# Backup, notarize and upload the testnet chain
# Uses the various scripts to perform the backup located in teh /scripts dir

user="fr1t2"
BACKUP_PATH=/home/"$user"/qrl-chain-state-backup/qrl_bootstrap_files
BOOTSTRAP_LOGS="$BACKUP_PATH"/qrl_bootstrap.logs

echo "----------------------------------------------" | tee -a "$BOOTSTRAP_LOGS" 
echo "[$(date -u)] QRL.CO.IN Testnet Backup" |tee -a "$BOOTSTRAP_LOGS"
echo "Backup, Notarize and upload for Testnet" | tee -a "$BOOTSTRAP_LOGS"  
echo "----------------------------------------------" | tee -a "$BOOTSTRAP_LOGS"  


## Backup the chain state
echo "Backup Chain....." | tee -a "$BOOTSTRAP_LOGS"  
sudo -H -u "$user" pwd
sudo -H -u "$user" /home/"$user"/qrl-chain-state-backup/CreateQRLBootstrap-testnet.sh
echo "Backup Chain Complete!" | tee -a "$BOOTSTRAP_LOGS"  

## Notarize the state checksum file
echo "Notarize....." | tee -a "$BOOTSTRAP_LOGS"  
sudo -H -u "$user" /home/"$user"/qrl-chain-state-backup/script/notarize-testnet.sh
echo "Notarize Complete!" | tee -a "$BOOTSTRAP_LOGS"  

## Load to the Cloud
echo "Upload to Cloud....." | tee -a "$BOOTSTRAP_LOGS"  
sudo -H -u "$user" /home/"$user"/qrl-chain-state-backup/script/cloudUp-testnet.sh
echo "Upload to Cloud Complete!" | tee -a "$BOOTSTRAP_LOGS"
