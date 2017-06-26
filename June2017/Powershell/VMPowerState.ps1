# **********************************************
# **********************************************
#
# PowerShell to Manage Virtual Machine Power State in the DevInt Resource Group
#
# **********************************************
# **********************************************

# Define params
param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('01','02')]
    [System.String]$VirtualMachineNameIdSuffix,

    [Parameter(Position=1, Mandatory=$true)]
    [System.Boolean]$StartVM,

    [Parameter(Position=2, Mandatory=$false)]
    [System.Boolean]$ProcessAllVMs = $false
)

. "$PSScriptRoot\globals.ps1"

# Variables:
$credential
$rgName = 'RG-SC-Demo'
$vmNamePrefix = 'az12web'

if ($StartVM -eq $false)
{
    Write-Host("Information - You will be prompted with a confirmation to shutdown VM specified.")
}

# Function will be called by mainline code below
function PerformWork($vmId)
{
    $VirtualMachineName = $vmNamePrefix + $vmId

    # Get Status Code
    $vmStatus = get-azurermvm -ResourceGroupName $rgName  -Name $VirtualMachineName -Status 
    $vmStatusCode = $vmStatus.Statuses[1].Code
    Write-Host("Current VM $VirtualMachineName Status Code is $vmStatusCode")

    if ($vmStatusCode -eq 'PowerState/deallocated' -AND $StartVM -eq $true)
    {        
        # Start a Stopped (Deallocated) VM
        Write-Host("Starting VM " + $VirtualMachineName + " ... ")
        Start-AzureRMVm -ResourceGroupName $rgName -Name $VirtualMachineName

        Write-Host("Request Completed.")        

    }
    elseif($vmStatusCode -eq 'PowerState/running' -AND $StartVM -eq $false)
    {
        # Stop and Deallocate a Running VM
        Write-Host("Stopping VM " + $VirtualMachineName + " ... ")
        Stop-AzureRMVm -ResourceGroupName $rgName -Name $VirtualMachineName
        
        Write-Host("Request Completed.")     
           
    }
    else
    {
        Write-Host("Warning - No work performed!")
    }       
}


# **********************************************
# Perform Azure Login:
# Show non-Azure credential dialog to perform Azure Login

try
{
    # Show non-Azure credential dialog to perform Azure Login - Doesn't work with Microsoft Live account!!!
    # $credential = Get-Credential -Message "Login to you Azure Subscription"

    # Validate Azure Login
    # Login-AzureRmAccount -SubscriptionId $subscriptionId -Credential $credential -TenantId $tenantId ## - Doesn't work with Microsoft Live account!!! ##
    Login-AzureRmAccount -SubscriptionId $subscriptionId -TenantId $tenantId

    # $reservedBy = $credential.UserName 
    $reservedBy = (Get-AzureRmContext).Account.Id

}
catch
{
    Write-Host("Exception - Azure Login Failed!")
    exit $LASTEXITCODE
    return
}
# **********************************************

# **********************************************
try
{

    if ($ProcessAllVMs -eq $true)
    {       

        Write-Host("Processing all VMs...")

        $idx = 1
        while($idx -le 8)
        {
            if ($idx -le 8)
            {
                PerformWork("0$idx")
                $idx++
            }

        }

        Write-Host("Process Finished for all VMs.")

    }
    else
    {
        # Process only that one machine requested
        PerformWork($VirtualMachineNameIdSuffix)
    }   

}
catch
{
    Write-Host("Exception - Azure Login Failed!")
    exit $LASTEXITCODE
    return
}
# **********************************************