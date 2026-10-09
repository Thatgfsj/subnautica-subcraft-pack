# build-guest.ps1 - build the Minecraft-side NeoForge mod (1.21.1).
#   powershell -ExecutionPolicy Bypass -File scripts\build-guest.ps1
#
# Needs a JDK 21 on JAVA_HOME (or -JavaHome). The Gradle wrapper downloads Gradle itself.
# On a network where the JVM cannot reach the internet directly, set the proxy in
# GRADLE_USER_HOME\gradle.properties (systemProp.http(s).proxyHost/Port) - a plain
# "the browser works" is not enough, because the JVM ignores the system proxy.
param([string]$JavaHome = $env:JAVA_HOME)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$guest = Join-Path $root 'upstream-build\guest-neoforge'

if (-not $JavaHome -or -not (Test-Path $JavaHome)) {
    Write-Host 'ERROR: set JAVA_HOME to a JDK 21 (or pass -JavaHome).' -ForegroundColor Red
    exit 2
}
$env:JAVA_HOME = $JavaHome
Write-Host "java: $JavaHome"

Push-Location $guest
& .\gradlew.bat build --console=plain
$code = $LASTEXITCODE
Pop-Location
if ($code -ne 0) { Write-Host 'build failed' -ForegroundColor Red; exit $code }
Write-Host 'done: guest-neoforge\build\libs\subcraft-*.jar' -ForegroundColor Green
