# current powershell version on Windows server 2022 instance is 5.1
# we need to upgrade powershell to 7.2 version (it's LTS version)
# Powershell repo https://github.com/PowerShell/PowerShell
# by default, Systems Manager in "Run Command" -> Run Command -> Command Document -> "AWS-RunPowerShellScript"
# use powershell 5.1 version. for running powershell 7 version , we need to use 
# pwsh -Command 'the powershell command'

# Define the URL to the PowerShell MSI installer
$installerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.13/PowerShell-7.2.13-win-x64.msi"

# Define the local path where the installer will be saved
$installerPath = "$env:TEMP\PowerShell-7.2.13-win-x64.msi"

# Download the installer
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Install PowerShell from the MSI installer
Start-Process -Wait -FilePath msiexec.exe -ArgumentList "/i `"$installerPath`" /qn"

# Remove the installer file
Remove-Item -Path $installerPath

# Update the PATH environment variable to include PowerShell 7
$powerShell7Path = "C:\Program Files\PowerShell\7"
if ($env:Path -notlike "*$powerShell7Path*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$env:Path;$powerShell7Path", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "PowerShell 7.2.13 has been successfully installed and added to the PATH environment variable."
} else {
    Write-Host "PowerShell 7.2.13 is already installed and added to the PATH environment variable."
}
# Specify the path to PowerShell 7.2.13 executable
$pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
# Check if PowerShell 7.2.13 is installed
if (Test-Path $pwshPath) {
    Write-Host "PowerShell 7.2.13 is currently the active shell."
} else {
    Write-Host "PowerShell 7.2.13 is not installed or may have encountered an issue."
}


