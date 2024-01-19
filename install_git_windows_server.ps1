<powershell>
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
$gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe"
$gitInstallerPath = "C:\GitInstaller.exe"
Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $gitInstallerPath
Start-Process -FilePath $gitInstallerPath -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS='icons,ext\reg\shellhere,assoc,assoc_sh'"
Start-Sleep -Seconds 15
$env:Path += ";C:\Program Files\Git\cmd"
git clone https://gitlab.com/Andr1500/ssm_runbook_bluegreen.git "C:\ssm_runbook_bluegreen"
Copy-Item -Path "C:\ssm_runbook_bluegreen\application\index.html" -Destination "C:\inetpub\wwwroot\index.html"
iisreset
Remove-Item -Path $gitInstallerPath -Force
</powershell>
