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

## References

https://docs.microsoft.com/en-us/azure/storage/blobs/storage-how-to-mount-container-linux

https://github.com/Azure/azure-storage-fuse

