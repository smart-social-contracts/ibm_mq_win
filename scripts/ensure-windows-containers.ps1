$cli = "$Env:ProgramFiles\Docker\Docker\DockerCli.exe"
$desktopExe = "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
if (-not (Test-Path $cli)) { Write-Error "Docker Desktop CLI not found at $cli"; exit 1 }
$desktop = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if (-not $desktop -and (Test-Path $desktopExe)) { Start-Process -FilePath $desktopExe | Out-Null; Start-Sleep -Seconds 20 }
$retry = 0
$max = 3
$info = $null
do {
  $info = docker info 2>$null
  if ($LASTEXITCODE -eq 0) { break }
  Start-Sleep -Seconds 5
  $retry++
} while ($retry -lt $max)
if ($LASTEXITCODE -ne 0) { & $cli -SwitchWindowsEngine; Start-Sleep -Seconds 15 }
elseif ($info -match "OSType:\s+linux") { & $cli -SwitchWindowsEngine; Start-Sleep -Seconds 15 }
docker version
