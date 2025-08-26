param (
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

# Default fallback
$defaultPhp = "C:\wampnew64\bin\php\php7.4.33\php.exe"

# Read fallback from .php-default next to this script if present
$wrapperDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$fallbackFile = Join-Path $wrapperDir '.php-default'
if (Test-Path $fallbackFile) {
    try { $val = (Get-Content $fallbackFile -Raw).Trim(); if ($val) { $defaultPhp = $val } } catch {}
}

# Search for .php-version upwards
$dir = (Get-Location).ProviderPath
while ($dir) {
    $phpVersionFile = Join-Path $dir ".php-version"
    if (Test-Path $phpVersionFile) {
        $php = (Get-Content $phpVersionFile -Raw).Trim()
        break
    }
    $parent = Split-Path $dir -Parent
    if (-not $parent -or $parent -eq $dir) { break }
    $dir = $parent
}

if (-not $php) { $php = $defaultPhp }

try {
    if (-not [System.IO.Path]::IsPathRooted($php)) {
        $candidate = Join-Path $dir $php
        $resolved = Resolve-Path -LiteralPath $candidate -ErrorAction SilentlyContinue
        if ($resolved) { $php = $resolved.ProviderPath }
    }
} catch {}

if ($php -and (Test-Path $php)) {
    $item = Get-Item -LiteralPath $php
    if ($item.PSIsContainer) {
        $possible = Join-Path $php 'php.exe'
        if (Test-Path $possible) { $php = (Get-Item $possible).FullName } else { Write-Error ".php-version points to a directory but no php.exe: $php"; exit 1 }
    }
}

if (-not $php -or -not (Test-Path $php)) { Write-Error "PHP binary not found: $php"; exit 1 }

& "$php" @Args
exit $LASTEXITCODE
param (
    [Parameter(ValueFromRemainingArguments = $true)]
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )

    # Ruta por defecto si no existe .php-version
    $defaultPhp = "C:\wampnew64\bin\php\php7.4.33\php.exe"
    # Intentar leer fallback desde .php-default ubicado en la carpeta del wrapper
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $fallbackFile = Join-Path $scriptDir '.php-default'
    if (Test-Path $fallbackFile) {
        try { $content = (Get-Content $fallbackFile -Raw).Trim(); if ($content) { $defaultPhp = $content } } catch { }
    }

    # Buscar archivo .php-version en el directorio actual o superior
    $dir = (Get-Location).ProviderPath
    while ($dir) {
        $phpVersionFile = Join-Path $dir ".php-version"
        if (Test-Path $phpVersionFile) {
            $php = (Get-Content $phpVersionFile -Raw).Trim()
            break
        }
        # Obtener el directorio padre; si es igual al actual o vacío, detener (llegamos a la raíz)
        $parent = Split-Path $dir -Parent
        if (-not $parent -or $parent -eq $dir) {
            break
        }
        $dir = $parent
    }

    if (-not $php) {
        param (
            [Parameter(ValueFromRemainingArguments = $true)]
            [string[]]$Args
        )

        # Ruta por defecto si no existe .php-version
        $defaultPhp = "C:\wampnew64\bin\php\php7.4.33\php.exe"
        # Intentar leer fallback desde .php-default ubicado en la carpeta del wrapper
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        $fallbackFile = Join-Path $scriptDir '.php-default'
        if (Test-Path $fallbackFile) {
            try { $content = (Get-Content $fallbackFile -Raw).Trim(); if ($content) { $defaultPhp = $content } } catch { }
        }

        # Buscar archivo .php-version en el directorio actual o superior
        $dir = (Get-Location).ProviderPath
        $php = $null
        while ($dir) {
            $phpVersionFile = Join-Path $dir ".php-version"
            if (Test-Path $phpVersionFile) {
                $php = (Get-Content $phpVersionFile -Raw).Trim()
                break
            }
            # Obtener el directorio padre; si es igual al actual o vacío, detener (llegamos a la raíz)
            $parent = Split-Path $dir -Parent
            if (-not $parent -or $parent -eq $dir) {
                break
            }
            $dir = $parent
        }

        if (-not $php) {
            $php = $defaultPhp
        } else {
            # Si la ruta es relativa, combinar con el directorio donde se encontró .php-version
            try {
                if (-not [System.IO.Path]::IsPathRooted($php)) {
                    $candidate = Join-Path $dir $php
                    $resolved = Resolve-Path -LiteralPath $candidate -ErrorAction SilentlyContinue
                    if ($resolved) { $php = $resolved.ProviderPath }
                }
            } catch {
                # no crítico, se seguirá con el valor tal cual
            }

            # Si apunta a un directorio, asumir php.exe dentro
            if ($php -and (Test-Path $php) -and (Get-Item $php).PSIsContainer) {
                $possible = Join-Path $php 'php.exe'
                if (Test-Path $possible) { $php = (Get-Item $possible).FullName } else {
                    Write-Error ".php-version apunta a un directorio pero no contiene php.exe: $php"
                    exit 1
                }
            }
        }

        # Validar que el archivo exista (ruta absoluta final)
        if (-not $php -or -not (Test-Path $php)) {
            Write-Error "No se encontró el binario PHP en: $php"
            exit 1
        }

        # Ejecutar directamente el binario real (NO 'php', sino la ruta absoluta)
        & "$php" @Args
        exit $LASTEXITCODE
