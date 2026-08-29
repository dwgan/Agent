[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$skillDir = Join-Path $env:USERPROFILE '.agents\skills\easyeda-api'
$bridgeScript = Join-Path $skillDir 'scripts\bridge-server.mjs'
$nodeExe = (Get-Command node.exe -ErrorAction Stop).Source
$logDir = Join-Path $env:LOCALAPPDATA 'EasyEDA-Bridge'

function Find-EasyEDABridge {
    foreach ($port in 49620..49629) {
        try {
            $health = Invoke-RestMethod -Uri "http://127.0.0.1:$port/health" -TimeoutSec 1
            if ($health.service -eq 'easyeda-bridge') {
                return [pscustomobject]@{ Port = $port; Health = $health }
            }
        } catch {}
    }
    return $null
}

$bridge = Find-EasyEDABridge
if (-not $bridge) {
    if (-not (Test-Path -LiteralPath $bridgeScript)) {
        throw "Official EasyEDA Bridge entry not found: $bridgeScript"
    }

    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    Start-Process -FilePath $nodeExe `
        -ArgumentList $bridgeScript `
        -WorkingDirectory $skillDir `
        -RedirectStandardOutput (Join-Path $logDir 'bridge.log') `
        -RedirectStandardError (Join-Path $logDir 'bridge-error.log') `
        -WindowStyle Hidden

    $deadline = (Get-Date).AddSeconds(10)
    do {
        Start-Sleep -Milliseconds 250
        $bridge = Find-EasyEDABridge
    } until ($bridge -or (Get-Date) -ge $deadline)
}

if (-not $bridge) {
    throw 'EasyEDA Bridge did not become healthy on ports 49620-49629.'
}

Write-Output "EasyEDA Bridge port: $($bridge.Port)"
Write-Output "Health: $($bridge.Health | ConvertTo-Json -Compress)"
try {
    $windows = Invoke-RestMethod -Uri "http://127.0.0.1:$($bridge.Port)/eda-windows" -TimeoutSec 2
    Write-Output "EDA windows: $($windows | ConvertTo-Json -Depth 5 -Compress)"
} catch {
    Write-Warning "Unable to query EDA windows: $($_.Exception.Message)"
}
