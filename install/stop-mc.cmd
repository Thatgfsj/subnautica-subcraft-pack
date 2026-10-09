@echo off
rem stop-mc.cmd - stop the hidden Minecraft client this pack started.
rem Minecraft autosaves its world regularly; closing it here is the same as closing the window.
echo [SubCraft] stopping the SubCraft Minecraft client...
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'javaw.exe' -and $_.CommandLine -like '*subcraft*' } | ForEach-Object { Write-Host ('  stopping pid ' + $_.ProcessId); Stop-Process -Id $_.ProcessId -ErrorAction SilentlyContinue }"
echo [SubCraft] done. (If nothing was found, Minecraft was already closed.)
