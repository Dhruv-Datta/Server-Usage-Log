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
                query user /server:$server 2>&1
                query user /server:$server 2>&1 | Select-Object -Skip 1 | ForEach-Object {
                    $CurrentLine = $_.Trim() -Replace '\s+',' ' -Split '\s'
                    $newRow = New-Object System.Object # create an object to append to the array
                    $newRow | Add-Member -MemberType NoteProperty -Name "SERVER" -Value $server
                    $newRow | Add-Member -MemberType NoteProperty -Name "USERNAME" -Value $CurrentLine[0]

                    # if session is disconnected different fields will be selected
                    if ($CurrentLine[2] -eq 'Disc') {
                        Write-Host "_____________________"
                        Write-Host "Remote Computer: $server"
                        Write-Host "Username: $CurrentLine[0]"


                        # Create a PowerShell session to the remote computer
                        $session = New-PSSession -ComputerName $server

                        # Invoke commands on the remote computer to get CPU and RAM information
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

                        # Get CPU percentage for each running program
                        $processes = Invoke-Command -Session $session -ScriptBlock {
                            Get-WmiObject -Class Win32_PerfFormattedData_PerfProc_Process | Sort-Object -Property PercentProcessorTime -Descending | Select-Object -Property Name, PercentProcessorTime | Where-Object {$_.Name -ne "_Total"}
                        }

                        Write-Host "`nRunning Programs:"
                        $processes | ForEach-Object {
                            $name = $_.Name
                            $cpuPercentage = $_.PercentProcessorTime
                            Write-Host "Name: $name, CPU Percentage: $cpuPercentage%"
                        }

                        # Get total CPU usage for the entire computer
                        $totalCpuUsage = $computerCpuUsage

                        # Get total RAM usage for the entire computer
                        $totalRam = $computerRam.TotalVisibleMemorySize / 1MB
                        $totalRamUsage = $totalRam - ($computerRam.FreePhysicalMemory / 1MB)

                        Write-Host "`nTotal Computer CPU Usage: $totalCpuUsage%"
                        Write-Host "Total Computer RAM Usage: $totalRamUsage GB"

                        ####################################################################

                        $systemInfo = Invoke-Command -Session $session -ScriptBlock {
                            systeminfo | Out-String -Stream
                        }

                        # Process the system information to extract the physical memory value
                        $physicalMemory = ""
                        foreach ($line in $systemInfo) {
                            if ($line -match 'Total Physical Memory:') {
                                $physicalMemory = $line.ToString().Split(':')[1].Trim()
                                break
                            }
                        }

                        if ($physicalMemory -ne "") {
                            # The value was found
                            # Perform further operations here

                            $gbMemory = $physicalMemory.Substring(0, 2)
                            Write-Host "Total Computer RAM Storage: $gbMemory GB"
                        }
                    }
                    else {
                        Write-Host "_____________________"
                        Write-Host "Remote Computer: $server"
                        Write-Host "Username: $CurrentLine[0]"



                        # Create a PowerShell session to the remote computer
                        $session = New-PSSession -ComputerName $server

                        # Invoke commands on the remote computer to get CPU and RAM information
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

                        # Get CPU percentage for each running program
                        $processes = Invoke-Command -Session $session -ScriptBlock {
                            Get-WmiObject -Class Win32_PerfFormattedData_PerfProc_Process | Sort-Object -Property PercentProcessorTime -Descending | Select-Object -Property Name, PercentProcessorTime | Where-Object {$_.Name -ne "_Total"}
                        }

                        Write-Host "`nRunning Programs:"
                        $processes | ForEach-Object {
                            $name = $_.Name
                            $cpuPercentage = $_.PercentProcessorTime
                            Write-Host "Name: $name, CPU Percentage: $cpuPercentage%"
                        }

                        # Get total CPU usage for the entire computer
                        $totalCpuUsage = $computerCpuUsage

                        # Get total RAM usage for the entire computer
                        $totalRam = $computerRam.TotalVisibleMemorySize / 1MB
                        $totalRamUsage = $totalRam - ($computerRam.FreePhysicalMemory / 1MB)

                        Write-Host "`nTotal Computer CPU Usage: $totalCpuUsage%"
                        Write-Host "Total Computer RAM Usage: $totalRamUsage GB"

                        ####################################################################

                        $systemInfo = Invoke-Command -Session $session -ScriptBlock {
                            systeminfo | Out-String -Stream
                        }

                        # Process the system information to extract the physical memory value
                        $physicalMemory = ""
                        foreach ($line in $systemInfo) {
                            if ($line -match 'Total Physical Memory:') {
                                $physicalMemory = $line.ToString().Split(':')[1].Trim()
                                break
                            }
                        }

                        if ($physicalMemory -ne "") {
                            # The value was found
                            # Perform further operations here

                            $gbMemory = $physicalMemory.Substring(0, 2)
                            Write-Host "Total Computer RAM Storage: $gbMemory GB"
                        }
                    }
                    $csvContents += $newRow # append the new data to the array
                }
                Write-Host
            }
            catch {
                #Write-Host $_.Exception.Message
                Write-Host "[-] Server is not accessible: $server"
            }
        } else {
            Write-Host "[-] Could not find column 'Server Name' in CSV file provided, exiting..."
            break
        }
    }
    if ($csvContents) {
        $csvContents | Export-CSV $expCSV -UseCulture -NoTypeInformation -Encoding UTF8
        $csvFileName = Get-ChildItem $expCSV
        Write-Host "[+] Successfully exported to" $csvFileName.Name
    }
} else {
    Write-Host "[!] Could not read CSV file provided, exiting..."
}
Write-Host