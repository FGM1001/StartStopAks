<#

    .SYNOPSIS
    Script to stop a AKS cluster

    .DESCRIPTION

    


#>


<#
param(
    [Parameter(Mandatory = $true)][string]$AKSClusterName
    [Parameter(Mandatory = $true)][string]$AKSResourceGroupName
) 

#>

$AKSClusterName="AKSTest"
$AKSResourceGroupName="RG-AKS-Test"
$TenantID ="82f9ff5f-776f-4b4e-93e9-12839b767108"
$SubscriptionID = '376657bb-7cc3-4f52-b1e7-eb78c56b1802'

Login-AzAccount -Verbose


Set-AzContext -name "Microsoft Azure Enterprise (9a40f535-76b0-4123-ba2b-4bcf670be528) - dbb21a28-035f-42c1-b1b7-f8918f6416a4 - FMingo@kabel.es"
Set-AzContext -Tenant $TenantID
$Subscription =  Get-AzSubscription -SubscriptionId $SubscriptionID
Select-AzSubscription -Subscription $Subscription
$AKSCluster = Get-AzAksCluster -ResourceGroupName $AKSResourceGroupName -Name $AKSClusterName



Get-AzAksCluster