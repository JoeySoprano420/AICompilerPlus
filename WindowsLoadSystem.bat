@echo off
:: --- CONFIGURATION VARIABLES ---
set PROJECT_NAME="AI Compiler +"
set LOG_FILE=logs\system_load.log
set PYTHON_VENV_DIR=env
set EXECUTABLE_PATH=dist\ai_compiler_plus.exe
set CPLUSPLUS_BINARY=AI_Compiler_Plus\src\build\main_binary.exe
set REQUIRED_PORT=5000
set PORT_CHECK_SCRIPT=check_port.py

:: Create logs directory if it doesn't exist
if not exist logs (
    mkdir logs
)

echo ========================================= >> %LOG_FILE%
echo Starting %PROJECT_NAME% - Advanced Load Script >> %LOG_FILE%
echo Timestamp: %date% %time% >> %LOG_FILE%
echo ========================================= >> %LOG_FILE%

:: --- SYSTEM CHECKS ---
echo Performing system checks... >> %LOG_FILE%

:: Check for Python installation
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Python is not installed. Please install it and try again. >> %LOG_FILE%
    echo Python not found. Exiting.
    exit /b 1
)

:: Check for g++ (MinGW or other compatible compiler)
where g++ >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: g++ compiler not found. Please install it and try again. >> %LOG_FILE%
    echo g++ not found. Exiting.
    exit /b 1
)

:: Check if port is in use
echo Checking if port %REQUIRED_PORT% is already in use... >> %LOG_FILE%
python -c "import socket; s = socket.socket(); s.bind(('', %REQUIRED_PORT%))" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Port %REQUIRED_PORT% is in use. Please free it and restart. >> %LOG_FILE%
    echo Port %REQUIRED_PORT% is occupied. Exiting.
    exit /b 1
)

:: --- ENVIRONMENT SETUP ---
echo Setting up Python virtual environment... >> %LOG_FILE%
if not exist %PYTHON_VENV_DIR% (
    echo Creating virtual environment... >> %LOG_FILE%
    python -m venv %PYTHON_VENV_DIR%
)
call %PYTHON_VENV_DIR%\Scripts\activate

echo Installing Python dependencies... >> %LOG_FILE%
pip install --upgrade pip >> %LOG_FILE% 2>&1
pip install -r requirements.txt >> %LOG_FILE% 2>&1

:: --- SETTING UP C++ COMPONENTS ---
echo Setting up C++ binaries... >> %LOG_FILE%
if not exist %CPLUSPLUS_BINARY% (
    echo Compiling C++ project since binary not found... >> %LOG_FILE%
    cd AI_Compiler_Plus\src\build
    cmake ..
    mingw32-make -j %NUMBER_OF_PROCESSORS%
    cd ..\..\..
) else (
    echo C++ binary found. Skipping compilation. >> %LOG_FILE%
)

:: --- STARTING SYSTEM COMPONENTS ---
echo Launching %PROJECT_NAME% system components... >> %LOG_FILE%

:: 1. Launching Python server-based AI module
echo Starting Python AI module... >> %LOG_FILE%
start cmd /c "%EXECUTABLE_PATH% --port %REQUIRED_PORT%" >> %LOG_FILE% 2>&1

:: 2. Launching C++ task scheduler
echo Starting C++ task scheduler... >> %LOG_FILE%
start cmd /c "%CPLUSPLUS_BINARY%" >> %LOG_FILE% 2>&1

:: --- SYSTEM STATUS MONITORING ---
echo Monitoring system status... >> %LOG_FILE%
timeout /t 5 >nul

:: Check if Python AI module is running
netstat -ano | findstr :%REQUIRED_PORT% >nul
if %ERRORLEVEL% neq 0 (
    echo Error: Python AI module failed to start. >> %LOG_FILE%
) else (
    echo Python AI module is running on port %REQUIRED_PORT%. >> %LOG_FILE%
)

:: Check if C++ task scheduler is running
tasklist | findstr /i "main_binary.exe" >nul
if %ERRORLEVEL% neq 0 (
    echo Error: C++ task scheduler failed to start. >> %LOG_FILE%
) else (
    echo C++ task scheduler is running successfully. >> %LOG_FILE%
)

:: --- LOGGING PROCESS IDs ---
echo Logging process IDs... >> %LOG_FILE%
for /f "tokens=2 delims= " %%i in ('tasklist ^| findstr /i "ai_compiler_plus.exe"') do (
    echo Python AI module PID: %%i >> %LOG_FILE%
)
for /f "tokens=2 delims= " %%i in ('tasklist ^| findstr /i "main_binary.exe"') do (
    echo C++ Task Scheduler PID: %%i >> %LOG_FILE%
)

:: --- FINAL MESSAGE ---
echo ========================================= >> %LOG_FILE%
echo %PROJECT_NAME% has been successfully loaded! >> %LOG_FILE%
echo To stop the processes, use Task Manager or `taskkill /PID <PID>`. >> %LOG_FILE%
echo ========================================= >> %LOG_FILE%

:: Finish
echo System loaded successfully. Exiting.
