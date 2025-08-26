@echo off
rem Wrapper batch para ejecutar el binario PHP indicado en .php-version
rem Busca .php-version desde el directorio actual hacia arriba

setlocal enabledelayedexpansion
set "dir=%CD%"
set "defaultPhp=C:\wampnew64\bin\php\php7.4.33\php.exe"
rem Leer fallback desde archivo .php-default en la carpeta del wrapper si existe
set "wrapperDir=%~dp0"
set "fallbackFile=%wrapperDir%.php-default"
if exist "%fallbackFile%" (
	for /f "usebackq delims=" %%X in ("%fallbackFile%") do set "defaultPhp=%%~X"
)

:search
if exist "%dir%\.php-version" goto :found
for %%G in ("%dir%") do set "parent=%%~dpG"
rem quitar posible barra final
if defined parent if "%parent:~-1%"=="\" set "parent=%parent:~0,-1%"
if not defined parent goto :notfound
if /I "%parent%"=="%dir%" goto :notfound
set "dir=%parent%"
goto :search

:found
set "PHPPath="
for /f "usebackq delims=" %%a in ("%dir%\.php-version") do set "PHPPath=%%~a"
if "%PHPPath%"=="" set "PHPPath=%defaultPhp%"

rem Intentar resolver a ruta absoluta: si la ruta ya existe como file/abs, usarla; si no, probar relativa a %dir%
set "TestPath="
for %%T in ("!PHPPath!") do set "TestPath=%%~fT"
if not exist "!TestPath!" (
	if exist "%dir%\!PHPPath!" (
		for %%G in ("%dir%\!PHPPath!") do set "PHPPath=%%~fG"
	) else (
		rem dejar PHPPath tal cual (podría ser un comando o no existir)
	)
) else (
	set "PHPPath=!TestPath!"
)
set "TestPath="

rem Si PHPPath es un directorio, asumir php.exe dentro
if exist "!PHPPath!\" (
	if exist "!PHPPath!\php.exe" (
		for %%F in ("!PHPPath!\php.exe") do set "PHPPath=%%~fF"
	) else (
		echo .php-version apunta a un directorio pero no contiene php.exe: !PHPPath!
		endlocal & exit /b 1
	)
)

goto :runphp

:notfound
set "PHPPath=%defaultPhp%"

:runphp
rem Usar el valor tal cual (o fallback si está vacío)
if "!PHPPath!"=="" set "PHPPath=%defaultPhp%"

if not exist "!PHPPath!" (
	echo No se encontró el binario PHP en: !PHPPath!
	endlocal & exit /b 1
)

"!PHPPath!" %*
endlocal & exit /b %ERRORLEVEL%
