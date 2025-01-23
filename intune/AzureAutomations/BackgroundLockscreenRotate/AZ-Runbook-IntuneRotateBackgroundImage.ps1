#Set Policy ID and required scopes
$policyID = "POLICY ID FOR YOUR INTUNE BACKGROUND/LOCKSCREEN POLICY"

#Connect to MS Graph
try
{
    Connect-AzAccount -Identity
    Connect-MgGraph  -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

#Set API Endpoint, get Policy object, and get patch fields
$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$policyID"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri -OutputType PSObject
$patchfields = $response | Select-Object "@odata.context","@odata.type","personalizationDesktopImageUrl","personalizationLockScreenImageUrl"

#Get formatted date to use as image filename
$date = Get-Date -Format "yyyy-MM-dd"
$imagename = "background-$date.jpg"

#Set variables for storage account
$resourceGroupName = "RG OF THE SA"
$storageAccountName = "YOUR SA NAME"
$containerName = "YOUR CONTAINER NAME"

#Get the storage account context and list blobs in container
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$context = $storageAccount.Context
$blobs = Get-AzStorageBlob -Container $containerName -Context $context | Select-Object -expandproperty Name -verbose


    If ($blobs -contains $imagename) {
        Write-Host -ForegroundColor Green "Image file exists in storage container. Updating URL for image for week of $date"
        $imageURL = "https://yoursaname.blob.core.windows.net/yourcontainername/$imagename"
        $patchfields.personalizationDesktopImageUrl = "$imageURL"
        $patchfields.personalizationLockScreenImageUrl = "$imageURL"
        $jsonresponse = $patchfields | ConvertTo-Json -Depth 20
        Invoke-MgGraphRequest -Method PATCH "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$policyID" -ContentType "application/json" -Body $jsonresponse -verbose
}

    else
    {
        Write-Host -ForegroundColor Red "Image file not found in storage container. Using default background image"
        $imageURL = "https://yoursaname.blob.core.windows.net/yourcontainername/default.png"
        $patchfields.personalizationDesktopImageUrl = "$imageURL"
        $patchfields.personalizationLockScreenImageUrl = "$imageURL"
        $jsonresponse = $patchfields | ConvertTo-Json -Depth 20
        Invoke-MgGraphRequest -Method PATCH "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$policyID" -ContentType "application/json" -Body $jsonresponse -verbose
    }