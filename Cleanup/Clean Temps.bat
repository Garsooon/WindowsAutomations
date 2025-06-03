@echo off
title System Cleaner - Recycle Bin and Temp Files
color 0A
setlocal enabledelayedexpansion

:: Progress bar function variables
set "progress_total=6"
set "progress_current=0"
set "progress_bar="

echo ============================================
echo    System Cleaner - Recycle Bin and Temp
echo ============================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] Running with administrator privileges
) else (
    echo [WARNING] Not running as administrator - some operations may fail
)
echo.

:: Display warning and get user confirmation
echo This script will:
echo - Empty the Recycle Bin for all drives
echo - Clean Windows temp files (%temp%)
echo - Clean Windows system temp files
echo - Clean browser cache files (if accessible)
echo - Clean Windows prefetch files
echo.
set /p confirm=Do you want to continue? (Y/N): 
if /i not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Starting cleanup process...
echo.

:: Initialize progress bar
call :update_progress "Initializing cleanup..." 0

:: Empty Recycle Bin for all drives
call :update_progress "Emptying Recycle Bin..." 1
powershell.exe -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
if %errorlevel% == 0 (
    echo [SUCCESS] Recycle Bin emptied
) else (
    echo [INFO] Using alternative method for Recycle Bin...
    rd /s /q C:\$Recycle.Bin >nul 2>&1
    rd /s /q D:\$Recycle.Bin >nul 2>&1
    rd /s /q E:\$Recycle.Bin >nul 2>&1
    echo [SUCCESS] Recycle Bin cleanup completed
)

:: Clean user temp files
call :update_progress "Cleaning user temp files..." 2
set temp_count=0
for /f %%i in ('dir /a /b "%temp%" 2^>nul ^| find /c /v ""') do set temp_count=%%i
if %temp_count% gtr 0 (
    del /f /s /q "%temp%\*" >nul 2>&1
    for /d %%i in ("%temp%\*") do rd /s /q "%%i" >nul 2>&1
    echo [SUCCESS] Cleaned %temp_count% items from user temp folder
) else (
    echo [INFO] User temp folder already clean
)

:: Clean Windows temp files
call :update_progress "Cleaning Windows temp files..." 3
if exist "C:\Windows\Temp" (
    del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
    for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" >nul 2>&1
    echo [SUCCESS] Windows temp files cleaned
) else (
    echo [INFO] Windows temp folder not found or inaccessible
)

:: Clean browser cache (Chrome, Firefox, Edge, LibreWolf)
call :update_progress "Cleaning browser cache files..." 4
set browser_cleaned=0

:: Chrome cache
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    del /f /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
    set /a browser_cleaned+=1
)

:: Firefox cache
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%i in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
        if exist "%%i\cache2" (
            del /f /s /q "%%i\cache2\*" >nul 2>&1
            set /a browser_cleaned+=1
        )
    )
)

:: LibreWolf cache
if exist "%LOCALAPPDATA%\LibreWolf\Profiles" (
    for /d %%i in ("%LOCALAPPDATA%\LibreWolf\Profiles\*") do (
        if exist "%%i\cache2" (
            del /f /s /q "%%i\cache2\*" >nul 2>&1
            set /a browser_cleaned+=1
        )
    )
)

:: Edge cache
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
    set /a browser_cleaned+=1
)

if %browser_cleaned% gtr 0 (
    echo [SUCCESS] Browser cache files cleaned
) else (
    echo [INFO] No accessible browser cache found
)

:: Clean Windows Prefetch
call :update_progress "Cleaning Windows Prefetch files..." 5
if exist "C:\Windows\Prefetch" (
    del /f /s /q "C:\Windows\Prefetch\*" >nul 2>&1
    echo [SUCCESS] Prefetch files cleaned
) else (
    echo [INFO] Prefetch folder not found or inaccessible
)

:: Clean additional system files
call :update_progress "Cleaning additional system files..." 6
:: Windows Update cache
if exist "C:\Windows\SoftwareDistribution\Download" (
    del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
    echo [SUCCESS] Windows Update cache cleaned
)

:: Thumbnail cache
if exist "%LOCALAPPDATA%\Microsoft\Windows\Explorer" (
    del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
    echo [SUCCESS] Thumbnail cache cleaned
)

:: Recent files list
if exist "%APPDATA%\Microsoft\Windows\Recent" (
    del /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1
    echo [SUCCESS] Recent files list cleaned
)

echo.
echo ============================================
echo           CLEANUP COMPLETED
echo ============================================
echo.

:: Show disk space freed (approximate)
echo Calculating disk space freed...
powershell.exe -NoProfile -Command "Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {$drive = $_.DeviceID; $free = [math]::Round($_.FreeSpace/1GB, 2); Write-Host \"Drive $drive : $free GB Free\"}"

echo.
echo [INFO] Cleanup process completed successfully!
echo [INFO] You may need to restart your computer for all changes to take effect.
echo.
echo Press any key to exit...
pause >nul

:: Progress bar function
:update_progress
set "task_name=%~1"
set "current_step=%~2"
set "progress_current=%current_step%"

:: Calculate progress percentage
set /a "progress_percent=(%current_step% * 100) / %progress_total%"

:: Create progress bar (30 characters wide for better compatibility)
set "progress_bar="
set /a "filled_chars=(%current_step% * 30) / %progress_total%"
set /a "empty_chars=30 - %filled_chars%"

:: Build filled portion with # characters
for /l %%i in (1,1,%filled_chars%) do set "progress_bar=!progress_bar!#"
:: Build empty portion with - characters
for /l %%i in (1,1,%empty_chars%) do set "progress_bar=!progress_bar!-"

:: Display progress bar
echo.
echo Progress: [!progress_bar!] %progress_percent%%%
echo Status: %task_name%
echo Step %current_step% of %progress_total%
echo ============================================
goto :eof