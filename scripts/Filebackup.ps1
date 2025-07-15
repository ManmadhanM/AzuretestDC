param(
    [string]$StorageAccountName,
    [string]$ContainerName
)

# Install Az module if missing
if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
    Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser
}

# Login using the managed identity
Connect-AzAccount -Identity

# Create the context
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount

# Upload all files from D:\Backup to the container
$localFolder = "D:\Backup"
Get-ChildItem -Path $localFolder -File -Recurse | ForEach-Object {
    $relativePath = $_.FullName.Substring($localFolder.Length + 1)
    Set-AzStorageBlobContent -File $_.FullName -Container $ContainerName -Blob $relativePath -Context $ctx
}
