param (
    [Parameter(Mandatory=$true)]
    [string]$registrationToken
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
Invoke-WebRequest -Uri "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv" -OutFile "AVD-Agent.msi"
Invoke-WebRequest -Uri "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH" -OutFile "AVD-BootLoader.msi"

# Install new agent
Start-Process msiexec.exe -ArgumentList "/i AVD-Agent.msi /quiet REGISTRATIONTOKEN=$registrationToken" -Wait
Start-Process msiexec.exe -ArgumentList "/i AVD-BootLoader.msi /quiet" -Wait

# Restart
Restart-Computer -Force