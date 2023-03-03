# qrl-chain-state-backup
Backup blockchain state files to DigitalOcean spaces for serving through QRL.CO.IN for bootstrapping QRL nodes for faster spin-up and testing.  

The chain data is served from a link out of digital ocean https://cloud.digitalocean.com/spaces/qrl-chain and hosted on https://qrl.co.in/chain for the public to download.

Including the [QRL_bootstrap](https://github.com/0xFF0/QRL_bootstrap.git) sub-module for bootstrapping the QRL node and safely backing up the levelDB for the state.

## Setup

Clone the repo `git clone https://github.com/fr1t2/qrl-chain-state-backup.git`

Install the sub-module `git submodule init`

Update the sub-module `git submodule update`

Edit the configurations for each script to include any user or directory related changes throughout the scripts.

> Especially important is the $BACKUP_PATH in each file, this determines where the chain state will be copied to and zipped up from.

Ensure there is ample space to house these files as they grow in size. Mainnet is now `13GB`


### QRL Node

This script requires a fully synced node to be running in order to backup the state files. The scripts will look in the default directories for the qrl chain, `~/.qrl/` and `~/.qrl-testnet`. If you use a different location modify the scripts to fit.

Install the node following the [Official Instructions](https://docs.theqrl.org/node/QRLnode/)

### S3CMD

You will need to setup and authenticate with the DigitalOcean spaces API using the S3CMD program.

See this link to get started: 


### DigitalOcean Spaces

You will need to create a DigitalOcean account and setup a space to store the chain state files.

See this link to get started: https://docs.digitalocean.com/products/spaces/

> There are custom COORS settings that allow this to be served from the site without cross origin issues. See the settings in the digital ocean spaces dashboard for more.


## Usage

### backup-mainnet.sh

This script will backup the mainnet chain state to DigitalOcean spaces.

#### High level flow

```mermaid
graph TD
A[QRL Mainnet State Backup] --> |Backup|B[CreateQRLBootstrap-mainnet.sh]
A --> | Notarize |C[script/notarize-mainnet.sh] 
A --> |Upload|D[script/cloudUp-mainnet.sh]
click A "http://www.github.com/fr1t2/qrl-chain-state-backup"
click B "http://www.github.com/fr1t2/qrl-chain-state-backup/CreateQRLBootstrap-mainnet.sh"
click C "http://www.github.com/fr1t2/qrl-chain-state-backup/script/notarize-mainnet.sh"
click D "http://www.github.com/fr1t2/qrl-chain-state-backup/script/cloudUp-mainnet.sh"
```

<table>
<tr>
<td> CreateQRLBootstrap </td> <td> Notarize </td> <td> CloudUp </td>
</tr>
<tr>
<td> 

```mermaid
graph TD
A(CreateQRLBootstrap.sh) --> C[Copy Chain] 
C --> D[State] 
D --> E[verify.py]
E --> A
A --> F[tar database] 
F --- G[tar.gz]
G --> K[Checksums] 
K --> L[sha3]
K --> M[sha256]
K --> N[md5]
L --> O[ChecksumFile]
M --> O
N --> O
```

</td>
<td>

```mermaid
graph TD
A[QRL address] --> B[exists]
B --> |yes| C[Get Next OTS Key]
B --> |no| D[Create new QRL address]
D --> C
C --> E[Notarize]
E --> F[Collect Data]
```

</td>
<td>

```mermaid
graph TD
A[cloudUp.sh] --> B[State Files Up]
A --> C[Stats File Up]
A --> E[Checksum File Up]
```

</td>

</tr>
</table>

## Endpoints 

### Mainnet -

| Origin | Edge | Subdomain |
| --- | --- | --- |
| [QRL_Mainnet_State.tar.gz](https://qrl-chain.fra1.digitaloceanspaces.com/mainnet/QRL_Mainnet_State.tar.gz) | [QRL_Mainnet_State.tar.gz](https://qrl-chain.fra1.cdn.digitaloceanspaces.com/mainnet/QRL_Mainnet_State.tar.gz) | [QRL_Mainnet_State.tar.gz](https://cdn.qrl.co.in/mainnet/QRL_Mainnet_State.tar.gz) |
| [Mainnet_State_Checksums.txt](https://qrl-chain.fra1.digitaloceanspaces.com/mainnet/Mainnet_State_Checksums.txt) | [Mainnet_State_Checksums.txt](https://qrl-chain.fra1.cdn.digitaloceanspaces.com/mainnet/Mainnet_State_Checksums.txt) | [Mainnet_State_Checksums.txt](https://cdn.qrl.co.in/mainnet/Mainnet_State_Checksums.txt) |
| [QRL_Node_Stats.json](https://qrl-chain.fra1.digitaloceanspaces.com/mainnet/QRL_Mainnet_State_Stats.json) | [QRL_Node_Stats.json](https://qrl-chain.fra1.cdn.digitaloceanspaces.com/mainnet/QRL_Mainnet_State_Stats.json) | [QRL_Node_Stats.json](https://cdn.qrl.co.in/mainnet/QRL_Mainnet_State_Stats.json) |

### Testnet -

| Origin | Edge | Subdomain |
| --- | --- | --- |
| [QRL_Testnet_State.tar.gz](https://qrl-chain.fra1.digitaloceanspaces.com/testnet/QRL_Testnet_State.tar.gz) | [QRL_Testnet_State.tar.gz](https://qrl-chain.fra1.cdn.digitaloceanspaces.com/testnet/QRL_Testnet_State.tar.gz) | [QRL_Testnet_State.tar.gz](https://cdn.qrl.co.in/testnet/QRL_Testnet_State.tar.gz) |
| [Testnet_State_Checksums.txt](https://qrl-chain.fra1.digitaloceanspaces.com/testnet/Testnet_State_Checksums.txt) | [Testnet_State_Checksums.txt](https://qrl-chain.fra1.cdn.digitaloceanspaces.com/testnet/Testnet_State_Checksums.txt) | [Testnet_State_Checksums.txt](https://cdn.qrl.co.in/testnet/Testnet_State_Checksums.txt) |
| [QRL_Testnet_State_Stats.json](https://qrl-chain.fra1.digitaloceanspaces.com/testnet/QRL_Testnet_State_Stats.json) | [QRL_Testnet_State_Stats.json](https://qrl-chain.fra1.cdn.digitaloceanspaces.com/testnet/QRL_Testnet_State_Stats.json) | [QRL_Testnet_State_Stats.json](https://cdn.qrl.co.in/testnet/QRL_Testnet_State_Stats.json) |

