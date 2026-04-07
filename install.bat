@echo off
setlocal enabledelayedexpansion

set ROOT=%~dp0
set DB=%ROOT%db_server
set CAM=%ROOT%cam_server
set DB_VENV=%DB%\dbvenv\Scripts

echo ============================================================
echo  SF Server - Full Installation
echo ============================================================
echo.

echo [DB] Setting up db_server...
echo.

if exist "%DB%\dbvenv" (
    echo [DB] Stopping running processes...
    taskkill /F /FI "WINDOWTITLE eq SF API" >nul 2>&1
    taskkill /F /FI "WINDOWTITLE eq SF PLC Controller" >nul 2>&1
    taskkill /F /FI "WINDOWTITLE eq SF Dashboard" >nul 2>&1
    taskkill /F /IM uvicorn.exe >nul 2>&1
    taskkill /F /IM python.exe >nul 2>&1
    timeout /t 3 /nobreak >nul
    if exist "%DB%\dbvenv_old" rmdir /s /q "%DB%\dbvenv_old" >nul 2>&1
    rename "%DB%\dbvenv" dbvenv_old
    start "" /b cmd /c "timeout /t 5 /nobreak >nul && rmdir /s /q ""%DB%\dbvenv_old"" >nul 2>&1"
)

python -m venv "%DB%\dbvenv"
if %errorlevel% neq 0 (
    echo [DB] ERROR: Failed to create dbvenv. Is Python on PATH?
    pause & exit /b 1
)
echo [DB] dbvenv created.

echo [DB] Starting MySQL service...
net start MySQL81 >nul 2>&1
:wait_mysql_install
sc query MySQL81 | find "RUNNING" >nul 2>&1
if %errorlevel% neq 0 (
    timeout /t 2 /nobreak >nul
    goto wait_mysql_install
)
echo [DB] MySQL81 is running.

echo [DB] Installing Python dependencies...
"%DB_VENV%\pip.exe" install -r "%DB%\requirements.txt"
if %errorlevel% neq 0 ( echo [DB] ERROR: pip install failed. & pause & exit /b 1 )

echo [DB] Installing Node packages...
cd /d "%DB%\sf-dashboard"
npm install
if %errorlevel% neq 0 ( echo [DB] ERROR: npm install failed. Is Node.js on PATH? & pause & exit /b 1 )
cd /d "%ROOT%"

echo [DB] Running database setup...
"%DB_VENV%\python.exe" "%DB%\db_setup.py"
if %errorlevel% neq 0 ( echo [DB] ERROR: db_setup.py failed. & pause & exit /b 1 )

echo [DB] Done.
echo.

echo [CAM] Setting up cam_server...
echo.

if exist "%CAM%\venv" rmdir /s /q "%CAM%\venv"

echo [CAM] Creating virtual environment (Python 3.10)...
py -3.10 -m venv "%CAM%\venv"
if %errorlevel% neq 0 (
    echo [CAM] ERROR: Failed to create venv. Is Python 3.10 installed?
    pause & exit /b 1
)

echo [CAM] Installing requirements...
"%CAM%\venv\Scripts\pip.exe" install -r "%CAM%\requirements.txt"
if %errorlevel% neq 0 ( echo [CAM] ERROR: pip install failed. & pause & exit /b 1 )

echo [CAM] Done.
echo.

echo ============================================================
echo  Installation complete. Run start.bat to launch all services.
echo ============================================================
echo.
pause
