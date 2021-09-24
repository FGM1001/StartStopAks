    <#
    This runbook requires the Azure Automation Run-As (Service Principle) account, which must be added when creating the Azure Automation account.
    .PARAMETER  
        Parameters are read in from Azure Automation variables.  
        Variables (editable):
        -  AKSClusterName           :  ResourceGroup that contains VMs to be started. Must be in the same subscription that the Azure Automation Run-As account has permission to manage.
        -  AKSResourceGroupName     :  ResourceGroup that contains VMs to be stopped. Must be in the same subscription that the Azure Automation Run-As account has permission to manage.
 #>

<#
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Enter the name of the Cluster AKS")][String]$AKSClusterName,
        [Parameter(Mandatory=$true,HelpMessage="Enter the Resource Group Name where the cluster is")][String]$AKSResourceGroupName,
        [Parameter(Mandatory=$true,HelpMessage="Enter the action to execute (Start/Stop")][String]$Action
    )
#>
  
    # Login in Azure

$AKSClusterName = ""
$AKSResourceGroupName = ""
$Action="start"
$Attempt = 0
$MaxAttempts = 4
 
    Do{
        $connectionName = "AzureRunAsConnection"
        try
        {
            # Get the connection "AzureRunAsConnection "
            $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
            Add-AzAccount `
                -ServicePrincipal `
                -TenantId $servicePrincipalConnection.TenantId `
                -ApplicationId $servicePrincipalConnection.ApplicationId `
                -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
        
            Write-Output "Successfully logged into Azure subscription using Az cmdlets..."
        }
        catch 
        {
            if (!$servicePrincipalConnection)
            {
                $ErrorMessage = "Connection $connectionName not found."
                Write-Output $ErrorMessage
            }
            if ($Attempt -gt $MaxAttempts) 
            {
                Write-Output "$FailureMessage! Total retry attempts: $MaxAttempts"
                Write-Output "[Error Message] $($_.exception.message) `n"
            }
            else 
            {
                Write-Output "[$Attempt/$MaxAttempts] $FailureMessage. Retrying in 5 seconds..."
                Start-Sleep -Seconds 5
                $Attempt++
            }   
        }
    }while ($Attempt -le 3)

# Test Parameters

$Action=$Action.toLower()
$Context = Get-azcontext
$SubscriptionId = $Context.subscription.id 

$LaborDays=@('Monday', 'Tuesday','Wednesday','Thursday','Friday')
$Date = Get-Date
[string]$DayofWeek = $Date.DayOfWeek

if ($LaborDays -contains $DayofWeek){
    if ($Action -match "start"){
        try{
            $AKSCluster = Get-AzAksCluster -ResourceGroupName $AKSResourceGroupName -Name $AKSClusterName -Verbose -ErrorAction SilentlyContinue    
            Write-output "Cluster $AKSClusterName exist."
        }
        catch{
            Write-output "ERROR. Cluster $AKSClusterName not found."
            Write-Output $_.Exception
        }
        try{
            Start-AzAksCluster -ResourceGroupName $AKSResourceGroupName -SubscriptionId $SubscriptionId -Name $AKSClusterName -ErrorAction SilentlyContinue -verbose
        }
        catch{
            Write-output "Error. Starting cluster $AKSClusterName failed"
            Write-Output $_.Exception
        }
    }
    else{
        if ($Action -match "stop"){
            try{
                $AKSCluster = Get-AzAksCluster -ResourceGroupName $AKSResourceGroupName -Name $AKSClusterName -Verbose -ErrorAction SilentlyContinue
                Write-output "Cluster $AKSClusterName exist."
            }
            catch{
                Write-output "ERROR. Cluster $AKSClusterName not found."
                Write-Output $_.Exception
            }
            try{
                stop-akscluster -ResourceGroupName $AKSResourceGroupName -subscriptionid $SubscriptionId -name $AKSClusterName -ErrorAction silentlycontinue -verbose
            }
            catch{
                Write-output "Error. Starting cluster $AKSClusterName failed"
                Write-Output $_.Exception
            }
        }
    }
}


