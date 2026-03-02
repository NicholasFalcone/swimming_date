$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

if (-not $env:PLAYDATE_SDK_PATH -or [string]::IsNullOrWhiteSpace($env:PLAYDATE_SDK_PATH)) {
    $defaultSdk = 'C:\Users\nicho\Documents\PlaydateSDK'
    if (Test-Path (Join-Path $defaultSdk 'C_API\buildsupport\playdate_game.cmake')) {
        $env:PLAYDATE_SDK_PATH = $defaultSdk
    }
}

if (-not $env:PLAYDATE_SDK_PATH -or -not (Test-Path (Join-Path $env:PLAYDATE_SDK_PATH 'C_API\buildsupport\playdate_game.cmake'))) {
    Write-Error "PLAYDATE_SDK_PATH non impostata o non valida. Imposta la variabile all'SDK root, es: C:\PlaydateSDK"
}

$buildDir = Join-Path $repoRoot 'build'
if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

Set-Location $buildDir
cmake ..
cmake --build .

Write-Host "Build completata. Output in: $buildDir"
