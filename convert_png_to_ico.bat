@echo off
REM Check if ImageMagick is installed
where convert >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ImageMagick is required but not installed. Please install it from https://imagemagick.org.
    exit /b 1
)

REM Check if the correct number of arguments is passed
if "%~2"=="" (
    echo Usage: convert_png_to_ico.bat <input_png_file> <output_ico_file>
    exit /b 1
)

REM Input and Output files
set input_png=%1
set output_ico=%2

REM Check if the input PNG file exists
if not exist "%input_png%" (
    echo Input file %input_png% does not exist.
    exit /b 1
)

REM Convert PNG to ICO using ImageMagick
convert "%input_png%" -resize 64x64 "%output_ico%"

REM Check if the conversion was successful
if %ERRORLEVEL% equ 0 (
    echo Conversion successful: %input_png% -> %output_ico%
) else (
    echo Error: Conversion failed.
    exit /b 1
)
