# https://blogs.technet.microsoft.com/enterprisemobility/2015/12/10/custom-roles-in-azure-rbac-is-now-ga/

# Login Azure:
Login-AzureRmAccount 
Break

# Working through and build our understanding of what is really going on:
$roleName = 'DevTest Labs User'
#$roleName = 'Virtual Machine Contributor'

$actions = (get-azurermroledefinition $roleName).actions 

$noActions = (get-azurermroledefinition $roleName).notactions

$v = Get-AzureRmProviderOperation Microsoft.Network/publicIPAddresses/* #Microsoft.Compute/virtualMachines/*


# Adding custom role:
New-AzureRmRoleDefinition -InputFile '.\CustomRole.json'
Break

#Removing custom role:
Remove-AzureRmRoleDefinition -Name 'Custom - Limited VM Lab Operator' 
Break