@echo off
title System Diagnostics Tools Launcher
color 0B

echo ================================================
echo        System Diagnostics Tools Launcher
echo ================================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] Running with administrator privileges
) else (
    echo [WARNING] Not running as administrator - some features may be limited
)
echo.

echo This script will launch the following diagnostic tools:
echo.
echo 1. Event Viewer          - View system and application logs
echo 2. System Information    - Detailed system configuration
echo 3. Device Manager        - Hardware devices and status
echo 4. Installed Drivers     - Driver verification and details
echo.

set /p confirm=Do you want to launch all diagnostic tools? (Y/N): 
if /i not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo ================================================
echo         Launching Diagnostic Tools...
echo ================================================
echo.

:: Launch Event Viewer
echo [1/4] Opening Event Viewer...
start eventvwr.msc
echo [SUCCESS] Event Viewer launched
timeout /t 2 /nobreak >nul

:: Launch System Information
echo [2/4] Opening System Information...
start msinfo32.exe
echo [SUCCESS] System Information launched
timeout /t 2 /nobreak >nul

:: Launch Device Manager
echo [3/4] Opening Device Manager...
start devmgmt.msc
echo [SUCCESS] Device Manager launched
timeout /t 2 /nobreak >nul

:: Launch Driver Verifier Manager (for installed drivers)
echo [4/4] Opening Driver Information...
echo [INFO] Attempting to launch Driver Verifier Manager...
start verifier.exe
timeout /t 2 /nobreak >nul
echo [SUCCESS] Driver tools launched

echo.
echo ================================================
echo              Launch Summary
echo ================================================
echo.
echo Tools launched:
echo [OK] Event Viewer     - eventvwr.msc
echo [OK] System Info      - msinfo32.exe  
echo [OK] Device Manager   - devmgmt.msc
echo [OK] Driver Tools     - verifier.exe / devmgmt.msc
echo.
echo [INFO] All diagnostic tools have been launched.
echo [INFO] You can now switch between the opened windows.
echo.
echo Additional useful commands you can run manually:
echo - driverquery          : List all installed drivers
echo - pnputil /enum-drivers: Enumerate driver packages
echo - sfc /scannow         : System file checker
echo - dism /online /cleanup-image /checkhealth : System image health
echo.
echo ================================================
echo.

:: Offer to run additional diagnostic commands
echo Would you like to run additional diagnostic commands?
echo.
echo A. List all installed drivers (driverquery)
echo B. Show driver packages (pnputil)
echo C. Run system file check (sfc /scannow) - Requires Admin
echo D. Check system image health (DISM) - Requires Admin
echo E. Skip additional commands
echo.
set /p choice=Enter your choice (A-E): 

if /i "%choice%"=="A" goto run_driverquery
if /i "%choice%"=="B" goto run_pnputil
if /i "%choice%"=="C" goto run_sfc
if /i "%choice%"=="D" goto run_dism
if /i "%choice%"=="E" goto skip_commands
echo Invalid choice. Skipping additional commands.
goto skip_commands

:run_driverquery
echo.
echo Running driver query...
echo ================================================
driverquery
echo ================================================
goto script_end

:run_pnputil
echo.
echo Enumerating driver packages...
echo ================================================
pnputil /enum-drivers
echo ================================================
goto script_end

:run_sfc
echo.
echo Running System File Checker (this may take several minutes)...
echo ================================================
sfc /scannow
echo ================================================
goto script_end

:run_dism
echo.
echo Checking system image health (this may take several minutes)...
echo ================================================
dism /online /cleanup-image /checkhealth
echo ================================================
goto script_end

:skip_commands
echo Skipping additional commands.
goto script_end

:script_end

echo.
echo ================================================
echo         System Diagnostics Complete
echo ================================================
echo.
echo All requested diagnostic tools and commands have been executed.
echo Check the opened windows for system information and diagnostics.
echo.
echo Press any key to exit...
pause >nul