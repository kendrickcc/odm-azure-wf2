# OpenDroneMap IaC Terraform cloud-init Azure GitHub Actions

Infrastructure as Code (IaC) Build of OpenDroneMap using Terraform and cloud-init in Azure, deploying using GitHub Actions.

Preloading images to a storage container in Azure, then using `blobfuse` to connect to the container for processing. Using `RClone` to copy images to the Azure Blob container.

## Setup

### SSH key

Create a SSH key. The public key will be stored in GitHub as indicated below.

### AZ CLI

Using AZ CLI generate a service principal account, and storage account. Information will be stored as a GitHub secret.

### GitHub secrets

In the repository, navigate to `Settings` - `Secrets` - `Actions`. Create new secrets for the following:
```
- AZURE_AD_CLIENT_ID 	  - upload the clientId
- AZURE_AD_CLIENT_SECRET  - upload the clientSecret
- AZURE_AD_TENANT_ID	  - upload the tenantId
- AZURE_SUBSCRIPTION_ID   - upload the subscriptionId or a different subscription ID
- ID_RSA_WEBODM		  - upload the contents of the public key generated
- STORAGE_ACCOUNT_NAME	  - name of the storage account
- FUSE_ACCOUNTNAME	  - storage account name
- FUSE_ACCOUNTKEY	  - storage account access key
```
### Rclone

Rclone is capable of connecting to many hosts and to try and script all the keys and tokens and client IDs into cloud-init is a lot of work. Much simpler to scp up a local working config file.

Copy `rclone.conf` up to the remote VM.

***Note:*** I add the additional flags to keep from getting a lot of extra hosts added to the `known_hosts` file. It is likely to get the same public IP from a previous build and then SCP/SSH may not work.

	scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_webodm.pem ~/.config odm@[public IP]:

Connect to the server. 

	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_webodm.pem odm@[public IP address]

Test the connections. Get a list of remotes:

	rclone listremotes
	[list of remotes are provided]
	rclone lsd [remotename]: # the last colon is required

If successful, should see directories form the remote.

#### Rclone copy

#### Rclone drive mapping

Rclone is capable of mapping a drive. Create a mount point, then map the drive. `rclone mount` alone will run and mount leaving the session open and unable to interact. `Ctrl+C` will kill the command and unmount the drive. Using `--daemon` will put the command in the background. To stop Rclone `kill` the process ID.

	mkdir /odm/onedrive
	rclone --vfs-cache-mode writes mount OneDrive: /odm/onedrive # Ctrl+C to break and unmount
	rclone --vfs-cache-mode writes mount OneDrive: /odm/onedrive --daemon # Use `kill`

To map Google Drive folders that are shared with you:

	rclone mount GDrive: /odm/GDRive --drive-shared-with-me 

## Run ODM

### Single ODM

	docker run -ti --rm -v /odm/data/datasets:/datasets project opendronemap/odm --project-path /datasets

### With ClusterODM

First open a browser to ClusterODM port 8001 and add nodes. http://[public ip]:8001

	docker run -ti --rm -v /odm/data/datasets:/datasets project opendronemap/odm --project-path /datasets --split 800 --split-overlap 120 --sm-cluster http://192.168.100.4:3001

## References

https://docs.microsoft.com/en-us/azure/storage/blobs/storage-how-to-mount-container-linux

https://github.com/Azure/azure-storage-fuse

Rclone and personal OneDrive (https://itsfoss.com/use-onedrive-linux-rclone/)
Rclone mounting personal OneDrive (https://www.linuxuprising.com/2018/07/how-to-mount-onedrive-in-linux-using.html)pwd
Rclone and Google Drive (https://rclone.org/drive/#making-your-own-client-id)

