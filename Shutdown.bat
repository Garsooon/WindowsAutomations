@echo off
title Auto Shutdown Timer

net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
    echo.
) else (
    echo ================================
    echo    ADMINISTRATOR REQUIRED
    echo ================================
    echo This script requires administrator privileges to shutdown the computer.
    echo Please right-click on this batch file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo ================================
echo    AUTOMATIC SHUTDOWN TIMER
echo ================================
echo.

:input
set /p seconds="Enter shutdown time in seconds: "

if "%seconds%"=="" (
    echo Error: Please enter a valid number.
    echo.
    goto input
)

for /f "delims=0123456789" %%i in ("%seconds%") do (
    echo Error: Please enter numbers only.
    echo.
    goto input
)

if %seconds% LEQ 0 (
    echo Error: Please enter a number greater than 0.
    echo.
    goto input
)

echo.
echo Shutdown scheduled in %seconds% seconds.
echo Press Ctrl+C to cancel this batch file.
echo To cancel the shutdown, run: shutdown /a
echo.

echo Executing shutdown command...
shutdown /s /t %seconds% /c "Automatic shutdown initiated by timer"

if %errorlevel% EQU 0 (
    echo SUCCESS: Shutdown successfully scheduled!
    echo.
    echo The computer will shutdown in %seconds% seconds.
    echo To cancel the shutdown, open Command Prompt as admin and type: shutdown /a
) else (
    echo ERROR: Failed to schedule shutdown.
    echo Error code: %errorlevel%
    echo.
    echo Possible solutions:
    echo 1. Make sure you're running this file as administrator
    echo 2. Try running Command Prompt as administrator and use: shutdown /s /t %seconds%
    echo 3. Check if shutdown service is running
)

echo.
pause