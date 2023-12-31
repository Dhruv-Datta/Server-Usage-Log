# Server Usage Log
This documentation will cover 2 versions of the Server Usage Log, both designed to achieve a different purpose and cater to specific use cases. By providing an overview of each version, we aim to equip users with a comprehensive understanding of the capabilities and functionalities offered by the different iterations of the Usage Log.

All the System Usage Logs are tools designed to capture and record key information about the CPU usage and RAM Memory usage of remote servers. It serves as a valuable resource for administrators to understand why a server might have crashed and what applications led to the crash.

Another use case would be to understand if a server is coming a little too close to the max memory usage requirement. It can give you a good indicator of when to upgrade a server if the usage is being logged close to maximum capacity.

## Server Usage Log 1.0
This usage log is written in python and has a few moving parts to get it set up correctly. Use this Usage Log if you have fewer users to manage as the setup for this is a lot more combersome as the amount of users increase. I would say you can set this up on an organization with 1 - 20 people. 

In order for this log to be used in its full potential, we recommend the following setup process:
1. Download Server-Usage-Log-1.0.py
2. Convert into exe file

```cmd
pip install pyinstaller

cd C:\path\to\file\Server-Usage-Log-1.0.py

pyinstaller --onefile --noconsole Server-Usage-Log-1.0.py
```

3. Move the exe file to whichever computer you would like to use the usage log on
4. Create a folder with a text file "Task Manager Log.txt"
5. Put the exe file into the folder
6. Create Task Scheduler to run the exe at whatever incriment you would like (1 hour reccomended.)


## Server Usage Log 2.3
This usage log is written in powershell and is the flagship model of the usage log. Use this Usage Log if you have a multitude of users to manage. You can set this up on an organization with 1 - 1000+ people. 

In order for this powershell script to be setup, we recommend the following setup process: 
1. Download powershell script and place in a folder
2. Download the csv files listed in the Server Usage Log 2.3 setup folder (log.csv, recentlog.csv, servers.csv)
3. In servers.csv input all your server names in a column
4. In Server-Usage-Log-2.3.ps1, change the file paths in the code to the csv file paths:

```powershell
# path to recentlog.csv
$recentCSV = "C:\path\to\file\recentlog.csv"
# path to log.csv
$logCSV = "C:\path\to\file\log.csv"
# path to servers.csv
$csvFile = "C:\path\to\file\servers.csv"
```

4. Change path for batch file that runs the powershell script and download it
   
```batch
PowerShell.exe -WindowStyle Hidden -Command "C:\Path\to\file\Server-Usage-Log.ps1"
```

5. Setup the task scheduler to run the batch file every hour or 2 depending on the quantity of users (the more users, the higher time incriment for task scheduler is recommended)

That should be all the steps for the setup! You can now run your program whenever you would like with the batch file.
