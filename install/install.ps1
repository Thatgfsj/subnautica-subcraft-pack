# install.ps1 - SubCraft pack installer for the Subnautica side (ASCII only on purpose:
# PowerShell 5.1 misreads UTF-8 Chinese in scripts without a BOM).
#
# Run it from the pack's own folder, inside the Subnautica game root:
#     powershell -ExecutionPolicy Bypass -File install.ps1
#
# It checks the layout, refuses to run while the game is open, and writes a personalized
# steam-launch-options.txt (the line to paste into Steam -> Properties -> Launch Options).

param([string]$McLaunch = '')

$ErrorActionPreference = 'Stop'

$packDir = Split-Path -Parent $MyInvocation.MyCommand.Path      # <game>\SubCraft
$gameDir = Split-Path -Parent $packDir                          # <game>
$exe     = Join-Path $gameDir 'Subnautica.exe'
$plugin  = Join-Path $gameDir 'BepInEx\plugins\SubCraft\SubCraft.dll'
$core    = Join-Path $gameDir 'BepInEx\core\BepInEx.dll'
$modJar  = (Get-ChildItem (Join-Path $gameDir 'mods') -Filter 'subcraft-*.jar' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName)
if (-not $modJar) { $modJar = Join-Path $gameDir 'mods\subcraft-<version>.jar' }   # only for the error message
$outLine = Join-Path $packDir 'steam-launch-options.txt'

Write-Host '=== SubCraft pack installer ===' -ForegroundColor Cyan
Write-Host "game dir : $gameDir"

# 1) is this really the game root?
if (-not (Test-Path $exe)) {
    Write-Host 'ERROR: Subnautica.exe was not found next to the SubCraft folder.' -ForegroundColor Red
    Write-Host '       Unzip the pack INTO the game root, i.e. the folder that holds Subnautica.exe.'
    Write-Host '       (Steam: right-click Subnautica -> Manage -> Browse local files)'
    exit 2
}

# 2) never touch a running game
if (Get-Process -Name 'Subnautica' -ErrorAction SilentlyContinue) {
    Write-Host 'ERROR: Subnautica is running. Close the game and run this again.' -ForegroundColor Red
    exit 3
}

# 3) are the pack's own files in place?
$missing = @()
foreach ($f in @($core, $plugin, $modJar)) { if (-not (Test-Path $f)) { $missing += $f } }
if ($missing.Count -gt 0) {
    Write-Host 'ERROR: the pack looks incomplete. Missing:' -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "       $_" }
    exit 4
}
Write-Host 'files    : BepInEx core OK, SubCraft.dll OK, subcraft mod jar OK' -ForegroundColor Green

# 4) config defaults (BepInEx writes the rest on first launch)
$cfgDir = Join-Path $gameDir 'BepInEx\config'
New-Item -ItemType Directory -Force $cfgDir | Out-Null
$cfg = Join-Path $cfgDir 'dev.subcraft.host.cfg'
if (-not (Test-Path $cfg)) {
    @'
[Debug]

## Dev save slot for the in-game test harness. Leave EMPTY for normal play: with no slot set,
## the harness refuses to load or save anything, so your own saves are never touched.
DevSlot =

[Hud]

## Show Minecraft's own GUI (hotbar, screens) on top of Subnautica.
ShowMinecraftOverlay = true

## Show Minecraft's health/hunger in Subnautica's dials.
UnifiedHud = true

[Player]

## Hide Subnautica's diver while Minecraft drives the player.
HideDiver = true
'@ | Set-Content -Path $cfg -Encoding UTF8
    Write-Host "config   : wrote $cfg"
} else {
    Write-Host "config   : kept existing $cfg"
}

# 5) fill in the launcher path in start-mc.cmd (only when still a placeholder or -McLaunch given)
$startMc = Join-Path $packDir 'start-mc.cmd'
$placeholder = '__MC_LAUNCH__'
$candidates = @()
if ($McLaunch) { $candidates += $McLaunch }
$candidates += @(
    'H:\Minecraft\Plain Craft Launcher 2.exe',
    "$env:USERPROFILE\Desktop\Plain Craft Launcher 2.exe",
    "$env:USERPROFILE\Desktop\PCL2.exe",
    'C:\Program Files\Plain Craft Launcher 2\Plain Craft Launcher 2.exe'
)
foreach ($dir in @("$env:USERPROFILE\Desktop", "$env:USERPROFILE\Downloads", 'H:\Minecraft', 'D:\Minecraft')) {
    if (Test-Path $dir) {
        Get-ChildItem $dir -Filter '*.exe' -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match 'Plain Craft|PCL|HMCL|Prism|MultiMC' } |
            ForEach-Object { $candidates += $_.FullName }
    }
}
$found = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (Test-Path $startMc) {
    $text = [System.IO.File]::ReadAllText($startMc, [System.Text.Encoding]::UTF8)
    if ($found) {
        $text = $text -replace [regex]::Escape($placeholder), $found
        [System.IO.File]::WriteAllText($startMc, $text, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "launcher : $found"
    } elseif ($text -match [regex]::Escape($placeholder)) {
        Write-Host 'launcher : NOT detected - edit MC_LAUNCH in start-mc.cmd yourself' -ForegroundColor Yellow
    }
}

# 6) personalized Steam launch options
$line = 'cmd /c start "" "' + $startMc + '" & %command%'
@(
    'Paste the line below into:',
    '  Steam -> Library -> right-click Subnautica -> Properties -> General -> Launch Options',
    '',
    $line,
    '',
    'What it does: starts your Minecraft launcher first, then the game. Minecraft hides its own',
    'window, opens the SubCraft world and waits for Subnautica to link up.',
    'Edit MC_LAUNCH in start-mc.cmd if the launcher path is wrong.'
) | Set-Content -Path $outLine -Encoding UTF8
Write-Host "launch   : wrote $outLine" -ForegroundColor Green
Write-Host ''
Write-Host '--- copy this line into Steam -> Subnautica -> Properties -> Launch Options ---'
Write-Host $line -ForegroundColor Yellow
Write-Host '------------------------------------------------------------------------------'
Write-Host ''
Write-Host 'Next: put mods\subcraft-0.0.1.jar into your Minecraft 1.21.1 + NeoForge instance mods folder,' -ForegroundColor Cyan
Write-Host '      start the game from Steam, load a CREATIVE save, and wait for the link.' -ForegroundColor Cyan
