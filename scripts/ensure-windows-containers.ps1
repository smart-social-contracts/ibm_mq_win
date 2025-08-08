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
if ($LASTEXITCODE -ne 0) { & $cli -SwitchWindowsEngine; $switched = $true; Start-Sleep -Seconds 15 }
elseif ($info -match "OSType:\s+linux") { & $cli -SwitchWindowsEngine; $switched = $true; Start-Sleep -Seconds 15 }
$tries = 0
$maxTries = 12
do {
  docker version
  if ($LASTEXITCODE -eq 0) { break }
  Start-Sleep -Seconds 5
  $tries++
} while ($tries -lt $maxTries)
if ($LASTEXITCODE -ne 0) {
  Write-Error "Docker Desktop Windows engine not ready. Ensure Docker Desktop is running and switched to Windows containers, then rerun."
  exit 1
}
$info2 = docker info 2>$null
if ($LASTEXITCODE -ne 0 -or ($info2 -notmatch "OS/Arch:\s+windows/amd64")) {
  Write-Error "Docker is not in Windows containers mode (OS/Arch != windows/amd64). Open Docker Desktop and Switch to Windows containers."
  exit 1
}
