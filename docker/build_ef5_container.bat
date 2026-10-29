@echo off
setlocal EnableDelayedExpansion

:: Default verified variables
set ALPINE_VERSION=3.17
set REPO=https://github.com/HyDROSLab/EF5.git
set BRANCH=master
set HAS_CUSTOM=false

:: Check for custom source injection in the main project directory
if exist "..\custom_sources.env" (
    echo Detected custom_sources.env file.
    set HAS_CUSTOM=true
    
    :: Parse the .env file, ignoring lines starting with # and extracting key=value
    for /f "usebackq eol=# tokens=1,* delims==" %%A in ("..\custom_sources.env") do (
        :: %%~B removes surrounding quotes from the value if they exist
        set %%A=%%~B
    )
)

echo ======================================
echo  Select EF5 Source Repository:
echo ======================================
echo  1) Default: HyDROSLab Original (master)
echo  2) Active Fork: AHWALab (master)
if "%HAS_CUSTOM%"=="true" (
    echo  3) Custom Injection (Loaded from .env)
)
echo ======================================
set /p choice="Enter choice: "

if "%choice%"=="1" (
    echo Selected: HyDROSLab Original
    set REPO=https://github.com/HyDROSLab/EF5.git
    set BRANCH=master
    set ALPINE_VERSION=3.17
    set ORG_NAME=hydroslab
    goto build
)

if "%choice%"=="2" (
    echo Selected: AHWALab Active Fork
    set REPO=https://github.com/AHWALab/EF5.git
    set BRANCH=master
    set ALPINE_VERSION=3.17
    set ORG_NAME=ahwalab
    echo.
    echo WARNING: The AHWALab fork renamed the inundation parameter from 'th_inu' to 'th_fim'. Ensure your control.txt reflects this change to avoid silent runtime errors.
    echo.
    :: Pause for 3 seconds so the user reads the warning
    timeout /t 3 >nul
    goto build
)

if "%choice%"=="3" (
    if "%HAS_CUSTOM%"=="true" (
        echo Selected: Custom Injection
        set REPO=!EF5_REPO_URL!
        set BRANCH=!EF5_BRANCH!
        
        :: Set Alpine version if provided in the .env, else fallback to 3.17
        if not "!ALPINE_VERSION!"=="" (
            set ALPINE_VERSION=!ALPINE_VERSION!
        ) else (
            set ALPINE_VERSION=3.17
        )
        set ORG_NAME=custom
        goto build
    )
)

:: Fallback for invalid input
echo Invalid choice. Defaulting to HyDROSLab Original.
set REPO=https://github.com/HyDROSLab/EF5.git
set BRANCH=master
set ALPINE_VERSION=3.17
set ORG_NAME=hydroslab

:build
set TAG_NAME=ef5-%ORG_NAME%:%BRANCH%

echo Building Docker image: %TAG_NAME% with Alpine %ALPINE_VERSION%

:: The docker build command executed from the /docker directory
docker build ^
  --build-arg ALPINE_VERSION="%ALPINE_VERSION%" ^
  --build-arg EF5_REPO_URL="%REPO%" ^
  --build-arg EF5_BRANCH="%BRANCH%" ^
  -t "%TAG_NAME%" ^
  -t ef5-container:latest ^
  -f Dockerfile ..

echo.
pause