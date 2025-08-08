param(
  [string]$Queue="DEV.QUEUE.1",
  [string]$Qmgr="QM1",
  [string]$Msg="hello from CI"
)
$env:MQSAMP_USER_ID = $env:MQSAMP_USER_ID -as [string]
$env:MQSAMP_USER_PWD = $env:MQSAMP_USER_PWD -as [string]

$cmdExe = $env:ComSpec
if (-not $cmdExe -or -not (Test-Path $cmdExe)) { $cmdExe = "C:\Windows\System32\cmd.exe" }

& $cmdExe /c "echo $Msg | amqsputc $Queue $Qmgr" | Write-Host
if ($LASTEXITCODE -ne 0) { Write-Error "amqsputc failed"; exit 3 }

amqsgetc $Queue $Qmgr
if ($LASTEXITCODE -ne 0) { Write-Error "amqsgetc failed"; exit 4 }
