Clear-Host
$ErrorActionPreference = "SilentlyContinue"
Write-Host
Write-Host "+--------------------------------+"
Write-Host "| --- Remote Logged On Users --- |"
Write-Host "+--------------------------------+"
Write-Host ""

$expCSV = "C:\Scripts\UpWork\Server-Usage-Log\log.csv"
$csvFile = "C:\Scripts\UpWork\Server-Usage-Log\servers.csv"
$csv = Import-Csv $csvFile -UseCulture

$titleSection = "Remote Computer, Process, Process Usage, Total CPU Usage, Total RAM Usage, Total RAM"
$titleSection | Add-Content -Path 'C:\Scripts\UpWork\Server-Usage-Log\log.csv'
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

                # Create a PowerShell session to the remote computer
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
                    Get-Process | Sort-Object WorkingSet64 | Select-Object Name, @{Name = 'WorkingSet'; Expression = { ($_.WorkingSet64 / 1MB) } }
                }

                $systemInfo = Invoke-Command -Session $session -ScriptBlock {
                    systeminfo | Out-String -Stream
                }

                # Aquires total system memory
                $physicalMemory = ""
                foreach ($line in $systemInfo) {
                    if ($line -match 'Total Physical Memory:') {
                        $physicalMemory = $line.ToString().Split(':')[1].Trim()
                        break
                    }
                }

                if ($physicalMemory -ne "") {
                    $gbMemory = $physicalMemory.Substring(0, 2)
                }

                Write-Host "`nRunning Programs:"
                $processes | ForEach-Object {
                    $name = $_.Name
                    $workingSet = $_.WorkingSet
                    Write-Host "Name: $name, Working Set: $workingSet MB"

                    $processData = "$server , $name , $workingSet MB , $computerCpuUsage% , $ramUsed GB, $gbMemory GB"
                    $processData | Add-Content -Path $expCSV
                }

                # Get total CPU usage for the entire computer
                $totalCpuUsage = $computerCpuUsage

                # Get total RAM usage for the entire computer
                $totalRam = $computerRam.TotalVisibleMemorySize / 1MB
                $totalRamUsage = $totalRam - ($computerRam.FreePhysicalMemory / 1MB)

                Write-Host "`nTotal Computer CPU Usage: $totalCpuUsage%"
                Write-Host "Total Computer RAM Usage: $totalRamUsage GB"
                Write-Host "Total Computer RAM Storage: $gbMemory GB"

                $newRow | Add-Member -MemberType NoteProperty -Name "USERNAME" -Value $null
                $newRow | Add-Member -MemberType NoteProperty -Name "PROCESS" -Value $null
                $newRow | Add-Member -MemberType NoteProperty -Name "PROCESS USAGE" -Value $null
                $newRow | Add-Member -MemberType NoteProperty -Name "TOTAL CPU USAGE" -Value $totalCpuUsage
                $newRow | Add-Member -MemberType NoteProperty -Name "TOTAL RAM USAGE" -Value $totalRamUsage
                $newRow | Add-Member -MemberType NoteProperty -Name "TOTAL RAM" -Value $gbMemory

                $csvContents += $newRow # append the new data to the array
                Write-Host
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

"" | Add-Content -Path 'C:\Scripts\UpWork\Server-Usage-Log\log.csv'
"" | Add-Content -Path 'C:\Scripts\UpWork\Server-Usage-Log\log.csv'