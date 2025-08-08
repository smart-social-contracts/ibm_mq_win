param(
  [string]$MqServerEnv
)

function Parse-MQSERVERHostPort {
  param([string]$mqserver)
  if (-not $mqserver) { return $null }

  # Expected format: CHLNAME/TRANSPORT/HOST(Port) e.g. DEV.APP.SVRCONN/TCP/host.docker.internal(1414)
  # Split on "/" and take the last segment for host/port
  $parts = $mqserver -split '/'
  if ($parts.Count -lt 3) { return $null }
  $hostPort = $parts[-1]

  # Extract host and port: something like "host(1414)"
  $host = $hostPort -replace '\(.*\)', ''
  $portMatch = [regex]::Match($hostPort, '\((\d+)\)')
  $port = if ($portMatch.Success) { $portMatch.Groups[1].Value } else { $null }

  if ([string]::IsNullOrWhiteSpace($host) -or -not $port) { return $null }

  [pscustomobject]@{
    Host = $host.Trim()
    Port = [int]$port
  }
}

$parsed = Parse-MQSERVERHostPort -mqserver $MqServerEnv
if (-not $parsed) {
  Write-Warning "Could not parse MQSERVER value '$MqServerEnv'. Expected format: CHL/TRANSPORT/HOST(Port)"
  exit 0
}

Write-Host "Preflight: testing connectivity to $($parsed.Host):$($parsed.Port) ..."
try {
  $result = Test-NetConnection -ComputerName $parsed.Host -Port $parsed.Port -WarningAction SilentlyContinue
} catch {
  $result = $null
}

if ($result -and $result.TcpTestSucceeded) {
  Write-Host "Preflight: SUCCESS - $($parsed.Host):$($parsed.Port) is reachable."
  exit 0
} else {
  Write-Warning "Preflight: WARNING - Unable to reach $($parsed.Host):$($parsed.Port). The smoke test may fail due to network/unavailable MQ."
  exit 0
}
