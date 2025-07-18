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

# Define old AVD agent product names to uninstall
$appList = @(
    "Remote Desktop Agent",
    "Remote Desktop Agent Boot Loader",
    "Remote Desktop Services Infrastructure Agent",
    "Remote Desktop Services Infrastructure Geneva Agent",
    "Remote Desktop Services Infrastructure Boot Loader",
    "Remote Desktop Services SxS Network Stack"
)

# Function to uninstall via msiexec using product code from registry
function Uninstall-AVDApp {
    param (
        [string]$appName
    )

    $keys = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse |
            Where-Object {
                ($_ | Get-ItemProperty).DisplayName -like "$appName*"
            }

    foreach ($key in $keys) {
        $props = Get-ItemProperty $key.PSPath
        $productCode = $props.PSChildName
        Write-Output "Uninstalling: $($props.DisplayName)"
        Start-Process msiexec.exe -ArgumentList "/x $productCode /quiet /norestart" -Wait
    }
}

# Uninstall matching apps
foreach ($app in $appList) {
    Uninstall-AVDApp -appName $app
}

Start-Sleep -Seconds 10

# Download the latest AVD Agent and Bootloader
Write-Output ">>> Downloading AVD Agent and BootLoader..."
Invoke-WebRequest -Uri "https://aka.ms/AVDAgent" -OutFile "AVD-Agent.msi"
Invoke-WebRequest -Uri "https://aka.ms/AVDBootLoader" -OutFile "AVD-BootLoader.msi"

# Install AVD Agent
Write-Output ">>> Installing AVD Agent..."
Start-Process msiexec.exe -ArgumentList "/i AVD-Agent.msi /quiet REGISTRATIONTOKEN=$registrationToken" -Wait

# Install BootLoader
Write-Output ">>> Installing BootLoader..."
Start-Process msiexec.exe -ArgumentList "/i AVD-BootLoader.msi /quiet" -Wait

# Optional: Install SxS Network Stack (if needed)
# Write-Output ">>> Installing SxS Network Stack..."
# Start-Process msiexec.exe -ArgumentList "/i AVD-BootLoader.msi /quiet REBOOT=ReallySuppress" -Wait

# Remove Session Host from Host Pool
Write-Output ">>> Removing session host from host pool..."
$sessionHostName = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"

# Install Az.DesktopVirtualization if not already installed
if (-not (Get-Module -ListAvailable -Name Az.DesktopVirtualization)) {
    Install-Module -Name Az.DesktopVirtualization -Force -Scope CurrentUser
}

Import-Module Az.DesktopVirtualization

Remove-AzWvdSessionHost -ResourceGroupName $resourceGroup `
                        -HostPoolName $hostPoolName `
                        -Name $sessionHostName `
                        -Force

Write-Output ">>> Session host '$sessionHostName' removed from host pool '$hostPoolName'."

# Final Reboot
Write-Output ">>> Rebooting system to finalize AVD agent reinstall..."
Restart-Computer -Force