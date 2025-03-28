@echo off
setlocal enabledelayedexpansion

:: Set paths for compilers and tools
set CPP_COMPILER=g++
set PYTHON_COMPILER=python
set PYINSTALLER=pyinstaller
set CXXFLAGS=-std=c++17

:: Set paths for source files and output
set SRC_DIR=src
set PY_SRC_DIR=python_src
set OUTPUT_DIR=output
set EXE_NAME=ai_compiler_plus

:: Clean previous builds
echo Cleaning previous builds...
if exist %OUTPUT_DIR% rd /s /q %OUTPUT_DIR%
mkdir %OUTPUT_DIR%

:: Step 1: Compile all C++ files into a single executable
echo Compiling C++ source files...
%CPP_COMPILER% %CXXFLAGS% %SRC_DIR%\*.cpp -o %OUTPUT_DIR%\%EXE_NAME%.exe

:: Check if C++ compilation was successful
if errorlevel 1 (
    echo C++ Compilation failed. Exiting.
    exit /b 1
)

:: Step 2: Bundle Python files using PyInstaller
echo Bundling Python files with PyInstaller...
cd %PY_SRC_DIR%
%PYINSTALLER% --onefile --distpath ../%OUTPUT_DIR%\dist --workpath ../%OUTPUT_DIR%\build my_python_script.py

:: Check if Python bundling was successful
if errorlevel 1 (
    echo Python bundling failed. Exiting.
    exit /b 1
)

:: Step 3: Combine C++ executable and Python bundle
echo Combining C++ and Python...
copy %OUTPUT_DIR%\dist\my_python_script.exe %OUTPUT_DIR%\combined_%EXE_NAME%.exe

:: Step 4: Cleanup temporary files
echo Cleaning up temporary files...
rd /s /q %OUTPUT_DIR%\build
rd /s /q %OUTPUT_DIR%\dist

echo Build completed successfully! The combined application is located in %OUTPUT_DIR%\combined_%EXE_NAME%.exe

:: Pause the script to allow the user to see the output
pause
