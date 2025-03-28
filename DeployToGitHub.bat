@echo off
setlocal enabledelayedexpansion

:: Set paths and GitHub repository details
set PROJECT_DIR=%cd%
set GIT_REMOTE=origin
set GIT_BRANCH=main
set GITHUB_URL=https://github.com/joeysoprano420/AI-COMPILER-PLUS.git

:: Ensure we're in the correct project directory
echo Checking project directory...
cd /d %PROJECT_DIR%

:: Step 1: Clean the project (optional, you can skip if not needed)
echo Cleaning project build directories...
if exist "output" rd /s /q "output"
if exist "build" rd /s /q "build"

:: Step 2: Add all new, modified, and deleted files to git
echo Adding files to git...
git add --all

:: Step 3: Commit changes
echo Enter commit message:
set /p COMMIT_MSG=
git commit -m "%COMMIT_MSG%"

:: Step 4: Check if the remote exists, if not add the GitHub remote
git remote get-url %GIT_REMOTE% >nul 2>nul
if errorlevel 1 (
    echo GitHub remote not found, adding remote...
    git remote add %GIT_REMOTE% %GITHUB_URL%
)

:: Step 5: Push the changes to the GitHub remote repository
echo Pushing changes to GitHub...
git push %GIT_REMOTE% %GIT_BRANCH%

:: Check if the push was successful
if errorlevel 1 (
    echo Git push failed. Please check your internet connection or authentication.
    exit /b 1
)

:: Step 6: Confirmation of success
echo Project successfully deployed to GitHub at %GITHUB_URL%!

:: Pause the script to allow the user to see the result
pause
