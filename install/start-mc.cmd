@echo off
rem start-mc.cmd - started by the Steam launch option before Subnautica.
rem Edit MC_LAUNCH below so it points at YOUR Minecraft launcher.
rem The pack's installer fills in a detected path when it can.
setlocal

set "MC_LAUNCH=__MC_LAUNCH__"

if "%MC_LAUNCH%"=="__MC_LAUNCH__" goto :nolauncher
if not exist "%MC_LAUNCH%" goto :nolauncher

echo [SubCraft] starting Minecraft launcher: %MC_LAUNCH%
start "" "%MC_LAUNCH%"
exit /b 0

:nolauncher
echo.
echo [SubCraft] No Minecraft launcher configured.
echo [SubCraft] Open this file (start-mc.cmd) and set MC_LAUNCH to your launcher's exe, e.g.
echo [SubCraft]     set "MC_LAUNCH=C:\Path\To\Plain Craft Launcher 2.exe"
echo [SubCraft] Then start Minecraft yourself, pick the 1.21.1 + NeoForge profile that has
echo [SubCraft] mods\subcraft-0.0.1.jar, and launch it.
echo.
rem Give the player a moment to read this, then carry on: Subnautica still starts.
timeout /t 5 >nul
exit /b 1
