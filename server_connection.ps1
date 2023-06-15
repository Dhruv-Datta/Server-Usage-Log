$remoteComputer = "CTO APPS17A"
$filePath = "C:\Dhruv\main_CTO-APPS17A.exe"

$scriptBlock = {
    param($filePath)
    Start-Process -FilePath $filePath -Wait
}

Invoke-Command -ComputerName $remoteComputer -ScriptBlock $scriptBlock -ArgumentList $filePath
