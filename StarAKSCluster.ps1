
workflow StopAks
{
    # Login in Azure
 
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
            Write-Output $_.Exception
        }

    $params = @{"AKSClusterName"="AKSTest";"AKSResourceGroupName"="RG-AKS-Test";"Action"="stop"}
    try{
        start-azautomationrunbook -AutomationAccountName "AutAKS" -name "StopAKSClusterPre" -ResourceGroupName "RG-AKS-TEST" -parameters $params
        
    }
    catch{
        write-Output "Error execution runbook StopAksClusterPre"
        Write-Output $_.Exception
        throw
    }
}