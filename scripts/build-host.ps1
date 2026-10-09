# build-host.ps1 - build the Subnautica-side BepInEx plugin (net472).
#   powershell -ExecutionPolicy Bypass -File scripts\build-host.ps1 [-GameDir <path>] [-Deploy]
param(
    [string]$GameDir = $env:SUBNAUTICA_DIR,
    [switch]$Deploy
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$proj = Join-Path $root 'upstream-build\host-subnautica'

if (-not $GameDir) { $GameDir = 'C:\Program Files (x86)\Steam\steamapps\common\Subnautica' }
if (-not (Test-Path (Join-Path $GameDir 'BepInEx\core\BepInEx.dll'))) {
    Write-Host "ERROR: BepInEx not found under $GameDir - install it first (the pack's install.ps1 does)." -ForegroundColor Red
    exit 2
}

# The upstream project reads SubnauticaDir from GamePath.props (untracked).
Set-Content -Path (Join-Path $proj 'GamePath.props') -Encoding UTF8 -Value @"
<Project>
  <PropertyGroup>
    <SubnauticaDir>$GameDir</SubnauticaDir>
  </PropertyGroup>
</Project>
"@

$deployArg = if ($Deploy) { '' } else { '-p:Deploy=false' }
Push-Location $proj
dotnet build SubCraft.Host.csproj $deployArg -v:m
Pop-Location
dotnet build-server shutdown | Out-Null
Write-Host 'done: host-subnautica\bin\Debug\net472\SubCraft.dll' -ForegroundColor Green
