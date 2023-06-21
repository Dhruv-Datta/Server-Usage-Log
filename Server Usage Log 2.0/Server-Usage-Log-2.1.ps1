Clear-Host
$ErrorActionPreference = "SilentlyContinue"
Write-Host
Write-Host "+--------------------------------+"
Write-Host "| ------ Server Usage Log ------ |"
Write-Host "+--------------------------------+"
Write-Host ""

$recentCSV = "C:\Scripts\UpWork\Server-Usage-Log\recentlog.csv"
$logCSV = "C:\Scripts\UpWork\Server-Usage-Log\log.csv"
$csvFile = "C:\Scripts\UpWork\Server-Usage-Log\servers.csv"
$csv = Import-Csv $csvFile -UseCulture

Clear-Content -Path $recentCSV

$titleSection = "Server, Username, Process, CPU Usage, Memory (MB), Total CPU Usage, Total RAM Usage (GB), Total RAM (GB)"
$titleSection | Add-Content -Path $logCSV
$titleSection | Add-Content -Path $recentCSV

Write-Host "[+] Title section successfully exported to file"

if ($csv) {
    $csvContents = @()
    Write-Host "[+] Querying servers, please be patient... (this can take a while)"
    Write-Host "oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo"
    Write-Host

    foreach ($row in $csv) {
        $server = $($row.'Server Name')

        if ($server) {
            try {
                Write-Host "[!] Trying server: " -NoNewline
                Write-Host $server -ForegroundColor "Green"
                query user /server:$server 2>&1 # Retrieve the logged-on users for the specified server.
                $newRow = New-Object System.Object # create an object to append to the array
                $newRow | Add-Member -MemberType NoteProperty -Name "SERVER" -Value $server

                $session = New-PSSession -ComputerName $server

                # Gets CPU and RAM information on Remote Computer
                $computerCpu = Invoke-Command -Session $session -ScriptBlock {
                    (Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_Processor).PercentProcessorTime | Measure-Object -Average | Select-Object -ExpandProperty Average
                }
                $computerIdle = Invoke-Command -Session $session -ScriptBlock {
                    (Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_Processor).PercentIdleTime | Measure-Object -Average | Select-Object -ExpandProperty Average
                }
                $computerCpuUsage = 100 - $computerIdle

                $computerRam = Invoke-Command -Session $session -ScriptBlock {
                    Get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property TotalVisibleMemorySize, FreePhysicalMemory
                }
                $ramUsed = ($computerRam.TotalVisibleMemorySize - $computerRam.FreePhysicalMemory) / 1MB

                $processes = Invoke-Command -Session $session -ScriptBlock {
                    Get-WmiObject -Class Win32_Process | Where-Object { $_.WorkingSetSize / 1MB -gt 200 }
                }

                foreach ($process in $processes) {
                    $processName = $process.Name
                    $processId = $process.ProcessId

                    $username = "Access Denied"

                    $processOwner = Invoke-Command -Session $session -ScriptBlock {
                        param($processId)
                        $query = "SELECT * FROM Win32_Process WHERE ProcessId = $processId"
                        $result = Get-WmiObject -Query $query

                        $owner = $result.GetOwner()
                        $owner.User
                    } -ArgumentList $processId

                    if ($processOwner -ne $null) {
                        $username = $processOwner
                    }

                    $ram = Invoke-Command -Session $session -ScriptBlock {
                        param($processId)
                        $query = "SELECT WorkingSetSize FROM Win32_Process WHERE ProcessId = $processId"
                        $result = Get-WmiObject -Query $query
                        $result.WorkingSetSize / 1MB
                    } -ArgumentList $processId

                    $cpuUsage = Invoke-Command -Session $session -ScriptBlock {
                        param($processId)
                        $query = "SELECT PercentProcessorTime FROM Win32_PerfFormattedData_PerfProc_Process WHERE IDProcess = $processId"
                        $result = Get-WmiObject -Query $query
                        $result.PercentProcessorTime
                    } -ArgumentList $processId

                    Write-Host "Server: $server"
                    Write-Host "Process Name: $processName"
                    Write-Host "Username: $username"
                    Write-Host "RAM (MB): $ram"
                    Write-Host "CPU Usage (%): $cpuUsage"
                    Write-Host "------------------------------"

                    $userData = "$server, $username, $processName, $cpuUsage%, $ram, $computerCpuUsage%, $ramUsed, $gbMemory"

                    $userData | Add-Content -Path $logCSV
                    $userData | Add-Content -Path $recentCSV
                }

                Write-Host "`nTotal Computer CPU Usage: $computerCpuUsage%"
                Write-Host "Total Computer RAM Usage: $ramUsed GB"
                Write-Host "Total Computer RAM Storage: $gbMemory GB"
                Write-Host ""

                Remove-PSSession -Session $session
            }
            catch {
                #Write-Host $_.Exception.Message
                Write-Host "[-] Server is not accessible: $server"
            }
        }
        else {
            Write-Host "[-] Could not find column 'Server Name' in CSV file provided, exiting..."
            break
        }
    }
}
else {
    Write-Host "[!] Could not read CSV file provided, exiting..."
}

Write-Host

"" | Add-Content -Path $logCSV
"" | Add-Content -Path $logCSV
