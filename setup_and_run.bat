@echo off
title AI Compiler+ Setup and Launch
cls

echo ================================================
echo        AI Compiler+ Setup and Installation      
echo ================================================
echo.
echo This script will set up the entire environment, 
echo restore dependencies, build the project, and run 
echo the AI Compiler+ application.
echo.
pause

:: Check for Administrator Privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo.
    echo Please run this script as Administrator.
    echo Exiting setup...
    pause
    exit /b
)

:: Set environment variables
set SOLUTION_FILE=AI_Compiler_Plus.sln
set BUILD_CONFIGURATION=Release
set BUILD_PLATFORM=x64
set ERROR_LOG=error_log.txt

:: Install Chocolatey (for dependency management)
echo Installing Chocolatey package manager (if not already installed)...
powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'; if (!(Get-Command choco -ErrorAction SilentlyContinue)) { iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex }"
if %errorlevel% neq 0 (
    echo Failed to install Chocolatey. Please check your internet connection or try manually.
    echo Exiting setup...
    pause
    exit /b
)

:: Install dependencies with Chocolatey
echo Installing required tools and dependencies...
choco install nuget -y
choco install visualstudio2019buildtools -y
choco install dotnetcore-sdk -y
choco install cmake -y
choco install python -y
choco install git -y
choco install mingw -y
if %errorlevel% neq 0 (
    echo Failed to install one or more dependencies. Please review the logs and try again.
    echo Exiting setup...
    pause
    exit /b
)

:: Restore NuGet packages
echo Restoring NuGet packages...
nuget restore %SOLUTION_FILE%
if %errorlevel% neq 0 (
    echo NuGet restore failed. Please check your NuGet installation and project configuration.
    echo Exiting setup...
    pause
    exit /b
)

:: Build the solution using MSBuild
echo Building the project using MSBuild...
msbuild %SOLUTION_FILE% /m /p:Configuration=%BUILD_CONFIGURATION% /p:Platform=%BUILD_PLATFORM%
if %errorlevel% neq 0 (
    echo Build failed. Check the build logs for errors.
    echo Error log saved to %ERROR_LOG%.
    echo Exiting setup...
    pause
    exit /b
)

:: Launch the AI Compiler+ application after successful build
echo Build succeeded! Launching the AI Compiler+ application...
set APP_PATH=.\bin\%BUILD_CONFIGURATION%\%BUILD_PLATFORM%\AI_Compiler_Plus.exe
if exist %APP_PATH% (
    start %APP_PATH%
) else (
    echo Application executable not found at %APP_PATH%.
    echo Please check the build output and path configuration.
)

echo ================================================
echo        AI Compiler+ Setup Completed!
echo ================================================
echo If the application did not launch, please review 
echo the logs and ensure all dependencies are installed.
echo.
pause
