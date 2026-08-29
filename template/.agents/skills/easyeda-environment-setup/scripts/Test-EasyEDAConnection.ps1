[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$bridge = $null

foreach ($port in 49620..49629) {
    try {
        $health = Invoke-RestMethod -Uri "http://127.0.0.1:$port/health" -TimeoutSec 1
        if ($health.service -eq 'easyeda-bridge') {
            $windows = Invoke-RestMethod -Uri "http://127.0.0.1:$port/eda-windows" -TimeoutSec 2
            $bridge = [pscustomobject]@{ Port = $port; Health = $health; Windows = $windows }
            break
        }
    } catch {}
}

if (-not $bridge) {
    throw 'No EasyEDA Bridge was found on ports 49620-49629.'
}

Write-Output "Health: $($bridge.Health | ConvertTo-Json -Compress)"
Write-Output "EDA windows: $($bridge.Windows | ConvertTo-Json -Depth 5 -Compress)"

if ($bridge.Windows.count -eq 0) {
    throw 'Bridge is healthy, but no EasyEDA window is connected.'
}
if ($bridge.Windows.count -gt 1) {
    throw 'Multiple EasyEDA windows are connected. Select an active window before API validation.'
}

$code = 'const project=await eda.dmt_Project.getCurrentProjectInfo();const document=await eda.dmt_SelectControl.getCurrentDocumentInfo();return {projectName:project?.friendlyName||project?.name||null,projectUuid:project?.uuid||null,documentType:document?.documentType??null,documentUuid:document?.uuid||null,tabId:document?.tabId||null};'
$body = @{
    code = $code
    windowId = $bridge.Windows.activeWindowId
} | ConvertTo-Json -Compress

$result = Invoke-RestMethod `
    -Method Post `
    -Uri "http://127.0.0.1:$($bridge.Port)/execute" `
    -ContentType 'application/json' `
    -Body $body `
    -TimeoutSec 35

if (-not $result.success) {
    throw "Read-only EDA API validation failed: $($result | ConvertTo-Json -Depth 10 -Compress)"
}

Write-Output "Read-only API result: $($result | ConvertTo-Json -Depth 20 -Compress)"
