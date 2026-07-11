@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
chcp 65001 >nul

if not exist "%SCRIPT_DIR%BOTC.exe" (
    echo BOTC.exe was not found in this folder.
    pause >nul
    exit /b 1
)

"%SCRIPT_DIR%BOTC.exe"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
    echo.
    echo BOTC server console closed with an error. Press any key to close.
    pause >nul
)

exit /b %EXIT_CODE%
