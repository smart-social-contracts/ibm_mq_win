param([string]$SourceZip = "C:\_thirdparty\ibm\mq\9.2\mqredist.zip",
      [string]$DestZip   = "$PSScriptRoot\..\mqredist.zip")
if (-not (Test-Path $SourceZip)) {
  Write-Error "IBM MQ redist ZIP not found at $SourceZip. Place it there or pass -SourceZip."
  exit 2
}
Copy-Item $SourceZip $DestZip -Force
Write-Host "Staged $SourceZip -> $DestZip"
