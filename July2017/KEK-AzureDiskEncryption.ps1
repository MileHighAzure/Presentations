
## Original Source: https://blogs.technet.microsoft.com/privatecloud/2016/09/15/taking-backup-of-encrypted-azure-vms-with-ade-azure-disk-encryption-using-azure-backup-in-oms/

########################################################################################################
# Section1:  Log-in to Azure and select appropriate subscription.
########################################################################################################

Login-AzureRmAccount -ErrorAction “Stop” 1> $null;
Get-AzureRmSubscription -SubscriptionName <your-subscription-name> | Select-AzureRmSubscription

 ## Register the Keyvault Resource Provider on your subscription before attempting this.

########################################################################################################
# Section2:  Define the variables required Log-in to Azure and select appropriate subscription.
########################################################################################################

$rgName = ‘xxx’;
$aadAppName = 'xxxx';

$keyVaultName = ‘xxxx’;

$keyEncryptionKeyName = ‘xxxx’;

$backupVMName = ‘xxxx’;

$recoveryServicesVaultName = 'xxx';

## RecoveryVault Service Principal Name is universal across all azure tenants

$recoveryServicesAADServicePrincipalName = ‘262044b1-e2ce-469f-a196-69ab7ada62d3’;

########################################################################################################
# Section3:  Create your Azure AD application & Key Vault for using in ADE & ABU
########################################################################################################

#  Create a new AD application if not created before

$identifierUri = [string]::Format(“http://localhost:8080/{0}”,[Guid]::NewGuid().ToString(“N”));
$defaultHomePage = ‘http://contoso.com’;
$now = [System.DateTime]::Now;
$oneYearFromNow = $now.AddYears(1);
$aadClientSecret = [Guid]::NewGuid(); $ADApp = New-AzureRmADApplication -DisplayName $aadAppName -HomePage $defaultHomePage -IdentifierUris $identifierUri  -StartDate $now -EndDate $oneYearFromNow -Password $aadClientSecret;
$servicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $ADApp.ApplicationId;
 

# Get Resource Group object to crease Key Vault

$resGroup = Get-AzureRmResourceGroup -Name $rgName
$location = $resGroup.Location
 

# Create a new vault if vault doesn’t exist

$keyVault = New-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $rgName -Sku Standard -Location $location;

# Add a new Key to Key Vault for using in Disk Encryption for VMs

$key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name $keyEncryptionKeyName -Destination ‘Software’
 

########################################################################################################
# Section4:  Get your Azure AD application’s client ID
########################################################################################################

$aadAppSvcPrincipals = (Get-AzureRmADServicePrincipal -SearchString $aadAppName);
$aadClientID = $aadAppSvcPrincipals[0].ApplicationId;
 

########################################################################################################
# Section5:  Get Azure Key Vault account & set policies for Azure AD application to store & manage encryption keys & secrets
########################################################################################################

# Get Key Vault account’s Encryption Key, Resource ID and Key Encryption Key URL which are needed  for encrypting Azure VM:

$keyVault = Get-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $rgname;
$diskEncryptionKeyVaultUrl = $keyVault.VaultUri;

$keyVaultResourceId = $keyVault.ResourceId;

$keyEncryptionKeyUrl = (Get-AzureKeyVaultKey -VaultName $keyVaultName -Name $keyEncryptionKeyName).Key.kid;

 

# Specify full privileges to the key vault for the AAD application

Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $aadClientID -PermissionsToKeys all -PermissionsToSecrets all;
 

# Enable disk encryption policy in key vault for using ADE

Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -EnabledForDiskEncryption;
 

# Specify privileges for Azure Backup Service to access keys and secrets in key vault for VM Backup. Please note the Service Principal name to set which is unique to Azure Backup service

Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $rgName  -PermissionsToKeys backup,get,list -PermissionsToSecrets get,list  –ServicePrincipalName $recoveryServicesAADServicePrincipalName
 

########################################################################################################
# Section6:  Enable Disk Encryption on Azure VM using AAD application & Key Vault
########################################################################################################

# Use VM disk encryption extension to enable encryption (Bit Locker for Windows, for Linux)

Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $rgName -VMName $backupVMName -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -KeyEncryptionKeyUrl $keyEncryptionKeyUrl -KeyEncryptionKeyVaultId $keyVaultResourceId;

## If you need to disable the disk encrypttion, use this script:
## This is needed if you get an error about the VM needing to be deallocated in order to modify the encryption. Disable the Encryption, give it a few minutes, and re-encrypt it.

Disable-AzureRMVMDiskEncryption -ResourceGroupName $rgName -VMName KN-app01

########################################################################################################
# Section7:   Trigger Initial Backup of encrypted VM
########################################################################################################

# Set Azure Recovery Services Vault context for backup operations

$recoveryServicesVault = Get-AzureRmRecoveryServicesVault -ResourceGroupName $rgName -Name $recoveryServicesVaultName
Set-AzureRmRecoveryServicesVaultContext –Vault $recoveryServicesVault


# Get protection policy to be used for enabling encrypted VM backup. Here the default protection policy is used which you can replace with your custom created one.

$backupPolicy = Get-AzureRmRecoveryServicesBackupProtectionPolicy DefaultPolicy

# Enable encrypted VM backup using the selected protection policy

Enable-AzureRmRecoveryServicesBackupProtection -Policy $backupPolicy -Name $backupVMName -ResourceGroupName $rgName
######################################################################################################## # Section8:  Trigger initial backup on demand to create initial copy of VM
########################################################################################################

# Trigger Initial Backup of VM

$backupContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM -Name $backupVMName
$backupItem = Get-AzureRmRecoveryServicesBackupItem -Container $backupContainer -WorkloadType AzureVM -Name $backupVMName

$backupItem | Backup-AzureRmRecoveryServicesBackupItem

 

########################################################################################################
# Section9:   Restore encrypted VM from a specific recovery point object to a storage account for new VM creation
######################################################################################################### Get Recovery Points of encrypted VM backup

$recoveryKeyFileLocation = <path-to-key-file-location>
$recoveryPointID=Get-AzureRmRecoveryServicesBackupRecoveryPoint -Item $backupItem
$recoveryPoint = Get-AzureRmRecoveryServicesBackupRecoveryPoint -RecoveryPointId $recoveryPointID[0] -Item $backupItem -KeyFileDownloadLocation $recoveryKeyFileLocation

# Restore encrypted VM to a storage account for creating new VM

$recoveryStorageAccount = <your-recovery-storage-account>
$recoveryResourceGroup = <your-resource-group-for-recovery>

Restore-AzureRMRecoveryServicesBackupItem -RecoveryPoint $recoveryPointID[0] -StorageAccountName $recoveryStorageAccount -StorageAccountResourceGroupName $recoveryResourceGroup