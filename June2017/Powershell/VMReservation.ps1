# **********************************************
# **********************************************
#
# PowerShell to Manage Virtual Machine Tags in the DevInt Resource Group 
#
# **********************************************
# **********************************************


# Define params
param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('01','02')]
    [System.String]$VirtualMachineNameIdSuffix,

    [Parameter(Position=1, ParameterSetName='Reservation')]
    [switch]$CreateReservation,

    [Parameter(Position=1, ParameterSetName='Reservation')]
    [switch]$ReleaseReservation
)

. "$PSScriptRoot\globals.ps1"

# Variables:
$credential
$rgName = 'RG-SC-Demo'
$vmNamePrefix = 'az12web'
$availableReserveTagConst = 'Available'
$reservedBy = $availableReserveTagConst # Initial value is Available
$date = Get-Date

# **********************************************
# Validation:
if ($CreateReservation -eq $false -AND $ReleaseReservation -eq $false)
{
    Write-Host("No work to be performed as create and release reservation parameters are not provided!")
    exit $LASTEXITCODE
    return
}
# **********************************************


# **********************************************
# Perform Azure Login:

try
{

    # Show non-Azure credential dialog to perform Azure Login - Doesn't work with Microsoft Live account!!!
    $credential = Get-Credential -Message "Login to you Azure Subscription"
     
    # Validate Azure Login
     Login-AzureRmAccount -SubscriptionId $subscriptionId -Credential $credential -TenantId $tenantId ## - Doesn't work with Microsoft Live account!!! ##
    # Login-AzureRmAccount -SubscriptionId $subscriptionId -TenantId $tenantId

    $reservedBy = $credential.UserName 
    # $reservedBy = (Get-AzureRmContext).Account.Id

}
catch
{
    Write-Host("Exception - Azure Login Failed!")
    exit $LASTEXITCODE
    return
}
# **********************************************

# **********************************************
# Reserve VM: 
try
{
    $VirtualMachineName = $vmNamePrefix + $VirtualMachineNameIdSuffix
    
    # Get existing tags:
    $vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $VirtualMachineName 
    $vmTags = $vm.Tags

    if ($vmTags.Count -eq 0)
    {
        Write-Host("Error - VM has no tags, no work can be performed.")
        exit $LASTEXITCODE
        return
    }    
    
    # NOTE: Creating a new Hash collection for the VM Tags will overwrite existing tags collection!!!!
    #$vmTags = @{"ReservedBy" = "Peter Piper"; "POC2" = "N/A"}

    $vmCurrentReservedByTag = $vmTags.Get_Item("ReservedBy")

    if ($vmCurrentReservedByTag -eq '')
    {
        Write-Host("Error - VM has no reservation tags, no work can be performed.")
        exit $LASTEXITCODE
        return
    }

    Write-Host("Currently Reserved by: " + $vmCurrentReservedByTag)

    # Is this request valid?
    if ($CreateReservation -eq $true -AND $vmCurrentReservedByTag -eq $availableReserveTagConst)
    {
        
        Write-Host("Updating...")

        # Set reservation:
        $vmTags.Set_Item("ReservedBy", $reservedBy)
        $vmTags.Set_Item("ReservedStartDate", $date)

        Update-AzureRmVM -ResourceGroupName $rgName -VM $vm -Tags $vmTags

        Write-Host("Finished Reserving " + $VirtualMachineName)

    }
    elseif ($ReleaseReservation -eq $true -AND $vmCurrentReservedByTag -eq $reservedBy)
    {

        Write-Host("Updating...")

        $vmTags.Set_Item("ReservedBy", $availableReserveTagConst)
        $vmTags.Set_Item("ReservedStartDate", $availableReserveTagConst)

        Update-AzureRmVM -ResourceGroupName $rgName -VM $vm -Tags $vmTags

        Write-Host("Finished Releasing Reservation for " + $VirtualMachineName)

    }
    else
    {
        Write-Host("Warning - VM specified is already reserved by another person. No work performed.")
    }    

}
catch
{
    Write-Host("Exception - Azure Reservation Failed!")
    exit $LASTEXITCODE
    return
}
# **********************************************


function AddNewAzureResourceTags()
{
    # Not used, but can add new Azure Tags
    $vmTags.Add("ReservedBy", "Available")
    $vmTags.Add("ReservedStartDate", "Available")
    Update-AzureRmVM -ResourceGroupName $rgName -VM $vm -Tags $vmTags
    Break    
}
