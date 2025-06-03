@echo off
title System File Repair Tool
color 0C
setlocal enabledelayedexpansion

:: Progress bar variables
set "progress_total=2"
set "progress_current=0"

echo ================================================
echo          System File Repair Tool
echo ================================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% == 0 (
    echo [INFO] Running with administrator privileges - Good!
    echo.
) else (
    echo [ERROR] This script MUST be run as Administrator!
    echo.
    echo Please right-click this file and select "Run as administrator"
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo This tool will perform a comprehensive system repair by running:
echo.
echo 1. System File Checker (sfc /scannow)
echo    - Scans and repairs corrupted Windows system files
echo    - Duration: 5-15 minutes typically
echo.
echo 2. DISM Health Check (dism /online /cleanup-image /checkhealth)
echo    - Checks Windows image component store health
echo    - Duration: 2-5 minutes typically
echo.
echo [WARNING] This process may take 15+ minutes to complete.
echo [WARNING] Do not close this window or shut down your computer.
echo.

set /p confirm=Do you want to proceed with system repair? (Y/N): 
if /i not "%confirm%"=="Y" (
    echo Operation cancelled by user.
    echo Press any key to exit...
    pause >nul
    exit /b
)

echo.
echo ================================================
echo        Starting System Repair Process
echo ================================================

:: Initialize progress
call :update_progress "Initializing system repair..." 0

:: Get start time
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set /a "start_time=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

:: Step 1: Run System File Checker
call :update_progress "Running System File Checker (sfc /scannow)..." 1
echo ================================================
echo Starting sfc /scannow...
echo This will scan all protected system files and repair corrupted files.
echo.
echo Please wait - this may take several minutes...
echo.

sfc /scannow

set sfc_result=%errorlevel%
echo.
echo ================================================
if %sfc_result% == 0 (
    echo [SUCCESS] System File Checker completed successfully
    echo No integrity violations found or all issues were repaired.
) else (
    echo [INFO] System File Checker completed with exit code: %sfc_result%
    echo Check the results above for details on any issues found.
)
echo ================================================
echo.

:: Brief pause between operations
echo Preparing for next step...
timeout /t 3 /nobreak >nul

:: Step 2: Run DISM Health Check
call :update_progress "Running DISM Component Store Health Check..." 2
echo ================================================
echo Starting dism /online /cleanup-image /checkhealth...
echo This will check the health of the Windows image component store.
echo.
echo Please wait - this may take several minutes...
echo.

dism /online /cleanup-image /checkhealth

set dism_result=%errorlevel%
echo.
echo ================================================
if %dism_result% == 0 (
    echo [SUCCESS] DISM Health Check completed successfully
    echo Component store is healthy.
) else (
    echo [INFO] DISM Health Check completed with exit code: %dism_result%
    echo Check the results above for details.
)
echo ================================================
echo.

:: Calculate elapsed time
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set /a "end_time=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
set /a "elapsed_time=(%end_time% - %start_time%) / 100"
set /a "minutes=%elapsed_time% / 60"
set /a "seconds=%elapsed_time% %% 60"

echo ================================================
echo           SYSTEM REPAIR COMPLETE
echo ================================================
echo.
echo Repair Summary:
echo --------------
echo SFC Scan Result: 
if %sfc_result% == 0 (
    echo   [OK] No issues found or all issues repaired
) else (
    echo   [CHECK] Review SFC results above
)
echo.
echo DISM Health Check Result:
if %dism_result% == 0 (
    echo   [OK] Component store is healthy  
) else (
    echo   [CHECK] Review DISM results above
)
echo.
echo Total Time Elapsed: %minutes% minutes, %seconds% seconds
echo.
echo ================================================
echo.

:: Additional recommendations for endusers
echo Recommendations:
echo ---------------
if %sfc_result% neq 0 (
    echo - Review the SFC scan results above
    echo - Consider running: dism /online /cleanup-image /restorehealth
    echo - Check CBS.log file for detailed SFC information
)
if %dism_result% neq 0 (
    echo - Review the DISM results above  
    echo - Consider running: dism /online /cleanup-image /restorehealth
    echo - Ensure Windows Update is working properly
)
echo - Restart your computer to complete any pending repairs
echo - Run Windows Update to ensure system is up to date
echo.

echo System repair process completed.
echo Press any key to exit...
pause >nul

:: Progress bar function
:update_progress
set "task_name=%~1"
set "current_step=%~2"
set "progress_current=%current_step%"

:: Calculate progress percentage
set /a "progress_percent=(%current_step% * 100) / %progress_total%"

:: Create progress bar (30 characters wide)
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
echo ================================================
goto :eof