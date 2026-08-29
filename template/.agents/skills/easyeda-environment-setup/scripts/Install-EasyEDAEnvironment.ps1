[CmdletBinding()]
param(
    [string]$SkillRoot = (Join-Path $env:USERPROFILE '.agents\skills'),
    [string]$GatewayDownloadDir = (Join-Path $env:USERPROFILE 'Downloads'),
    [switch]$SkipGatewayDownload
)

$ErrorActionPreference = 'Stop'
$repoUrl = 'https://github.com/easyeda/easyeda-api-skill.git'
$gatewayApi = 'https://api.github.com/repos/easyeda/eext-run-api-gateway/releases/latest'
$skillDir = Join-Path $SkillRoot 'easyeda-api'

foreach ($command in 'git.exe', 'node.exe', 'npm.cmd') {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $command"
    }
}

New-Item -ItemType Directory -Path $SkillRoot -Force | Out-Null

if (-not (Test-Path -LiteralPath $skillDir)) {
    & git.exe clone $repoUrl $skillDir
    if ($LASTEXITCODE -ne 0) { throw 'Failed to clone the official easyeda-api-skill repository.' }
} else {
    if (-not (Test-Path -LiteralPath (Join-Path $skillDir '.git'))) {
        throw "Target exists but is not a Git repository: $skillDir"
    }

    $gitSafe = $skillDir.Replace('\', '/')
    $remote = (& git.exe -c "safe.directory=$gitSafe" -C $skillDir remote get-url origin).Trim()
    if ($remote -notmatch '^https://github\.com/easyeda/easyeda-api-skill(?:\.git)?$' -and
        $remote -notmatch '^git@github\.com:easyeda/easyeda-api-skill(?:\.git)?$') {
        throw "Target repository is not the official easyeda-api-skill: $remote"
    }

    $dirty = & git.exe -c "safe.directory=$gitSafe" -C $skillDir status --porcelain
    if ($dirty) {
        throw 'The official Skill repository has local changes. Refusing to update or overwrite it.'
    }

    & git.exe -c "safe.directory=$gitSafe" -C $skillDir pull --ff-only
    if ($LASTEXITCODE -ne 0) { throw 'Failed to update the official easyeda-api-skill repository.' }
}

if (-not (Test-Path -LiteralPath (Join-Path $skillDir 'SKILL.md'))) {
    throw 'SKILL.md is missing after installation.'
}

Push-Location $skillDir
try {
    if (Test-Path -LiteralPath (Join-Path $skillDir 'package-lock.json')) {
        & npm.cmd ci
    } else {
        & npm.cmd install
    }
    if ($LASTEXITCODE -ne 0) { throw 'npm dependency installation failed.' }
    & npm.cmd ls --omit=dev --depth=0
    if ($LASTEXITCODE -ne 0) { throw 'npm dependency validation failed.' }
} finally {
    Pop-Location
}

Write-Output "Official easyeda-api Skill is ready: $skillDir"

if ($SkipGatewayDownload) { return }

New-Item -ItemType Directory -Path $GatewayDownloadDir -Force | Out-Null
$headers = @{ 'User-Agent' = 'Codex-EasyEDA-Environment-Setup' }
$release = Invoke-RestMethod -Uri $gatewayApi -Headers $headers
$asset = $release.assets |
    Where-Object { $_.name -match '_zh-cn\.eext$' } |
    Select-Object -First 1
if (-not $asset) {
    $asset = $release.assets | Where-Object { $_.name -match '\.eext$' } | Select-Object -First 1
}
if (-not $asset) { throw 'The latest official Gateway release has no .eext asset.' }

$gatewayFile = Join-Path $GatewayDownloadDir $asset.name
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $gatewayFile -Headers $headers

$manifestText = & tar.exe -xOf $gatewayFile extension.json
if ($LASTEXITCODE -ne 0 -or -not $manifestText) { throw 'Unable to read extension.json from the Gateway package.' }
$manifest = $manifestText | ConvertFrom-Json
if ($manifest.name -ne 'run-api-gateway' -or $manifest.displayName -ne 'Run API Gateway') {
    throw 'Gateway manifest identity validation failed.'
}
if ($manifest.publisher -notmatch '^(EasyEDA|JLCEDA)$') {
    throw "Unexpected Gateway publisher: $($manifest.publisher)"
}

$hash = (Get-FileHash -LiteralPath $gatewayFile -Algorithm SHA256).Hash
Write-Output "Gateway release: $($release.tag_name)"
Write-Output "Gateway package: $gatewayFile"
Write-Output "Gateway publisher: $($manifest.publisher)"
Write-Output "Gateway EDA engine: $($manifest.engines.eda)"
Write-Output "Gateway SHA-256: $hash"
Write-Output 'Import this package in EasyEDA, enable it, and select both Allow External Interaction and Show in Top Menu.'
