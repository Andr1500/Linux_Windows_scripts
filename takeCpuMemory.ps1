$LogPath = "C:\PerfLogs\CPU_Memory.log"
$cpu     = Get-WmiObject -class Win32_processor -Property NumberOfCores, NumberOfLogicalProcessors
$mem     = (Get-CimInstance -class cim_physicalmemory | Measure-Object Capacity -Sum).Sum
$LogTime = Get-Date -Format "dd/MM/yyyy HH:mm"

$processes = Get-Process -IncludeUserName | ForEach-Object {
    if ($_.StartTime -gt 0) {
        $ts        = (New-TimeSpan -Start $_.StartTime -ErrorAction SilentlyContinue).TotalSeconds
        $cpuusage  = [Math]::Round($_.CPU * 100 / $ts / $cpu.NumberOfLogicalProcessors, 2)
        $starttime = $_.StartTime.ToString("dd/MM/yyyy HH:mm")
    } else {
        $cpuusage  = 0
        $starttime = 0
    }

    $memoryUsageMB     = [Math]::Round($_.WorkingSet / 1MB, 2)
    $memoryUsagePercent = [Math]::Round(($_.WorkingSet / $mem) * 100, 2)

    [PSCustomObject] @{
        "LogTime"             = "{0,-20}" -f $LogTime
        "CPU(%)"              = "{0,-10}" -f $cpuusage
        "CPU(s)"              = "{0,-10}" -f $_.CPU
        "Memory(%)"           = "{0,-10}" -f $memoryUsagePercent
        "Memory(MB)"          = "{0,-15}" -f $memoryUsageMB
        "ProcessName"         = $_.ProcessName
        "ProcessID"           = "{0,-10}" -f $_.Id
        "UserName"            = $_.UserName
        "StartTime"           = "{0,-20}" -f $starttime
    }
}

$sortedProcesses = $processes | Sort-Object -Property "Memory(MB)" -Descending | Sort-Object -Property "CPU(%)" -Descending | Select-Object -First 20

# Column headers
$headers = "LogTime", "CPU(%)", "CPU(s)", "Memory(%)", "Memory(MB)", "ProcessName", "ProcessID", "UserName", "StartTime"

# Format the data as a table
$table = $sortedProcesses | Format-Table -AutoSize -Property $headers | Out-String

# Write the table to the log file (overwriting existing data)
Set-Content -Path $LogPath -Value $table -Encoding UTF8
