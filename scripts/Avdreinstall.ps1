param (
    [Parameter(Mandatory = $true)]
    [string]$registrationToken,

    [Parameter(Mandatory = $true)]
    [string]$hostPoolName,

    [Parameter(Mandatory = $true)]
    [string]$resourceGroup
)

$ErrorActionPreference = "Stop"

Write-Output ">>> Starting AVD Agent reinstall..."

# Uninstall old AVD agents
$appList = @(
  "Remote Desktop Services Infrastructure Agent",
  "Remote Desktop Services Infrastructure Geneva Agent",
  "Remote Desktop Services Infrastructure Boot Loader",
  "Remote Desktop Services SxS Network Stack"
)

foreach ($app in $appList) {
    Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$app*" } | ForEach-Object {
        Write-Output "Uninstalling: $($_.Name)"
        $_.Uninstall() | Out-Null
    }
}

Start-Sleep -Seconds 10

# Download AVD Agent and Bootloader
Write-Output ">>> Downloading AVD Agent and BootLoader..."
Invoke-WebRequest -Uri "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv" -OutFile "AVD-Agent.msi"
Invoke-WebRequest -Uri "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH" -OutFile "AVD-BootLoader.msi"

# Install AVD Agent and Bootloader
Write-Output ">>> Installing AVD Agent..."
Start-Process msiexec.exe -ArgumentList "/i AVD-Agent.msi /quiet REGISTRATIONTOKEN=$registrationToken" -Wait

Write-Output ">>> Installing BootLoader..."
Start-Process msiexec.exe -ArgumentList "/i AVD-BootLoader.msi /quiet" -Wait

# Optional: Install SxS Network Stack with reboot warning
Write-Output ">>> Installing SxS Network Stack (reboot may be required)..."
Start-Process msiexec.exe -ArgumentList "/i AVD-BootLoader.msi /quiet REBOOT=ReallySuppress" -Wait

# Remove Session Host from Host Pool
Write-Output ">>> Removing session host from host pool..."

# Construct full session host name
$sessionHostName = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"

# Install Az.DesktopVirtualization if not already installed
if (-not (Get-Module -ListAvailable -Name Az.DesktopVirtualization)) {
    Install-Module -Name Az.DesktopVirtualization -Force -Scope CurrentUser
}

Import-Module Az.DesktopVirtualization

# Log in to Azure if needed (skip if running with Managed Identity)
# Connect-AzAccount

Remove-AzWvdSessionHost -ResourceGroupName $resourceGroup `
                        -HostPoolName $hostPoolName `
                        -Name $sessionHostName `
                        -Force

Write-Output ">>> Session host '$sessionHostName' removed from host pool '$hostPoolName'."

# Final Reboot
Write-Output ">>> Rebooting system..."
Restart-Computer -Force
