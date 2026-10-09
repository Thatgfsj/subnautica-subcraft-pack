# make-pack.ps1 - assemble the release zip that players unzip into the Subnautica game root.
#   powershell -ExecutionPolicy Bypass -File scripts\make-pack.ps1 [-Version 0.1.0] [-SkipDownload]
#
# Layout of the zip (its root == the game root):
#   winhttp.dll, doorstop_config.ini, .doorstop_version, changelog.txt, BepInEx/core/*
#   BepInEx/plugins/SubCraft/SubCraft.dll
#   SubCraft/{README.txt,install.ps1,start-mc.cmd,stop-mc.cmd,steam-launch-options.template.txt}
#   mods/subcraft-<ver>.jar          (for the player's own NeoForge instance)
#   README.md, LICENSE, THIRD-PARTY-NOTICES.md
param(
    [string]$Version = '0.1.0',
    [string]$HostDll = '',
    [string]$ModJar = '',
    [string]$BepInExZip = '',
    [switch]$SkipDownload
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if (-not $HostDll) { $HostDll = Join-Path $root 'upstream-build\host-subnautica\bin\Debug\net472\SubCraft.dll' }
if (-not $ModJar) {
    $ModJar = Get-ChildItem (Join-Path $root 'upstream-build\guest-neoforge\build\libs') -Filter 'subcraft-*.jar' -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch 'sources|javadoc' } | Select-Object -First 1 -ExpandProperty FullName
}
foreach ($f in @($HostDll, $ModJar)) {
    if (-not $f -or -not (Test-Path $f)) { Write-Host "ERROR: missing build output: $f" -ForegroundColor Red; exit 2 }
}

# --- BepInEx 5.4.23.5 (LGPL, redistributed unmodified) -------------------------------
$bepUrl = 'https://github.com/BepInEx/BepInEx/releases/download/v5.4.23.5/BepInEx_win_x64_5.4.23.5.zip'
$bepSha = '82F9878551030F54657792C0740D9D51A09500EEAE1FBA21106B0C441E6732C4'
if (-not $BepInExZip) { $BepInExZip = Join-Path $root 'tools\BepInEx_win_x64_5.4.23.5.zip' }
if (-not (Test-Path $BepInExZip)) {
    if ($SkipDownload) { Write-Host "ERROR: BepInEx zip not found: $BepInExZip" -ForegroundColor Red; exit 3 }
    New-Item -ItemType Directory -Force (Split-Path $BepInExZip) | Out-Null
    Write-Host "downloading BepInEx 5.4.23.5"
    Invoke-WebRequest -Uri $bepUrl -OutFile $BepInExZip -UseBasicParsing
}
$hash = (Get-FileHash $BepInExZip -Algorithm SHA256).Hash
if ($hash -ne $bepSha) { Write-Host "ERROR: BepInEx zip hash mismatch: $hash" -ForegroundColor Red; exit 4 }
Write-Host 'BepInEx: hash OK'

# --- staging -------------------------------------------------------------------------
$dist = Join-Path $root 'dist'
$stage = Join-Path $dist "SubCraft-Subnautica-$Version"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force $stage | Out-Null

Expand-Archive -Path $BepInExZip -DestinationPath $stage -Force
$pluginDir = Join-Path $stage 'BepInEx\plugins\SubCraft'
New-Item -ItemType Directory -Force $pluginDir | Out-Null
Copy-Item $HostDll (Join-Path $pluginDir 'SubCraft.dll') -Force

$packDir = Join-Path $stage 'SubCraft'
New-Item -ItemType Directory -Force $packDir | Out-Null
Copy-Item (Join-Path $root 'install\install.ps1') $packDir -Force
Copy-Item (Join-Path $root 'install\start-mc.cmd') $packDir -Force
Copy-Item (Join-Path $root 'install\stop-mc.cmd') $packDir -Force
Copy-Item (Join-Path $root 'install\steam-launch-options.template.txt') $packDir -Force
Copy-Item (Join-Path $root 'README.md') $stage -Force
Copy-Item (Join-Path $root 'LICENSE') $stage -Force
Copy-Item (Join-Path $root 'THIRD-PARTY-NOTICES.md') $stage -Force

$modsDir = Join-Path $stage 'mods'
New-Item -ItemType Directory -Force $modsDir | Out-Null
Copy-Item $ModJar (Join-Path $modsDir ("subcraft-" + $Version + '.jar')) -Force

# --- zip ----------------------------------------------------------------------------
$zip = Join-Path $dist "SubCraft-Subnautica-$Version.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -CompressionLevel Optimal
$size = [int]((Get-Item $zip).Length / 1MB)
Write-Host "packed: $zip ($size MB)" -ForegroundColor Green
