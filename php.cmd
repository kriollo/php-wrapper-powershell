@echo off
rem Clean PHP wrapper - ASCII only
setlocal enabledelayedexpansion
set "dir=%CD%"
set "defaultPhp=C:\wampnew64\bin\php\php7.4.33\php.exe"
set "wrapperDir=%~dp0"
set "fallbackFile=%wrapperDir%.php-default"
if exist "%fallbackFile%" (
    for /f "usebackq delims=" %%X in ("%fallbackFile%") do set "defaultPhp=%%~X"
)

:search
if exist "%dir%\.php-version" goto :found
for %%G in ("%dir%") do set "parent=%%~dpG"
if defined parent if "%parent:~-1%"=="\" set "parent=%parent:~0,-1%"
if not defined parent goto :notfound
if /I "%parent%"=="%dir%" goto :notfound
set "dir=%parent%"
goto :search

:found
set "PHPPath="
for /f "usebackq delims=" %%a in ("%dir%\.php-version") do set "PHPPath=%%~a"
if "%PHPPath%"=="" set "PHPPath=%defaultPhp%"

set "TestPath="
for %%T in ("!PHPPath!") do set "TestPath=%%~fT"
if not exist "!TestPath!" (
    if exist "%dir%\!PHPPath!" (
        for %%G in ("%dir%\!PHPPath!") do set "PHPPath=%%~fG"
    )
) else (
    set "PHPPath=!TestPath!"
)
set "TestPath="

if exist "!PHPPath!\" (
    if exist "!PHPPath!\php.exe" (
        for %%F in ("!PHPPath!\php.exe") do set "PHPPath=%%~fF"
    ) else (
        echo .php-version points to a directory but no php.exe inside: !PHPPath!
        endlocal & exit /b 1
    )
)

goto :runphp

:notfound
set "PHPPath=%defaultPhp%"

:runphp
if "!PHPPath!"=="" set "PHPPath=%defaultPhp%"

if not exist "!PHPPath!" (
    echo PHP binary not found: !PHPPath!
    endlocal & exit /b 1
)

for %%R in ("!PHPPath!") do set "ResolvedPHP=%%~nxR"
if /I "!ResolvedPHP!"=="php.cmd" (
    echo .php-version resolves to the wrapper itself. Avoiding recursion.
    endlocal & exit /b 2
)

set "ResolvedOnPath="
for %%I in ("!PHPPath!") do set "ResolvedOnPath=%%~$PATH:I"
if defined ResolvedOnPath (
    set "WrapperFull=%~dp0php.cmd"
    if /I "!ResolvedOnPath!"=="!WrapperFull!" (
        echo 'php' in PATH points to this wrapper. Avoiding recursion.
        endlocal & exit /b 2
    )
)

"!PHPPath!" %*
endlocal & exit /b %ERRORLEVEL%
@echo off
