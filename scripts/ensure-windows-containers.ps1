$cli = "$Env:ProgramFiles\Docker\Docker\DockerCli.exe"
if (-not (Test-Path $cli)) { Write-Error "Docker Desktop CLI not found"; exit 1 }
$info = docker info 2>$null
if ($LASTEXITCODE -ne 0) { & $cli -SwitchWindowsEngine; Start-Sleep -Seconds 15 }
elseif ($info -match "OSType:\s+linux") { & $cli -SwitchWindowsEngine; Start-Sleep -Seconds 15 }
docker version
