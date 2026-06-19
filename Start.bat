@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
chcp 65001 >nul

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%startup-script.ps1"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
    echo.
    echo BOTC server console closed with an error. Press any key to close.
    pause >nul
)

exit /b %EXIT_CODE%
