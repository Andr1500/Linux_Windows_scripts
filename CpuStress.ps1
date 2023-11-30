# Create a directory for the StressCPU tool
$directoryPath = "C:\StressCPU"
New-Item -ItemType Directory -Path $directoryPath -Force | Out-Null

# Download StressCPU zip file
$zipUrl = "https://download.sysinternals.com/files/CPUSTRES.zip"
$zipFilePath = Join-Path $directoryPath "stresscpu.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFilePath

# Extract the contents
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, $directoryPath)

# Run StressCPU
$executablePath = Join-Path $directoryPath "CPUSTRES.EXE"
Start-Process -FilePath $executablePath -NoNewWindow
