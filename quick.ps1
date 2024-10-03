param (
    [Parameter(Mandatory = $true)]
    [string]$Name,
    
    [string]$Path = ""  # Parámetro opcional, el usuario puede pasar subcarpetas
)

# Validar que el nombre del componente no contenga caracteres no válidos
if ($Name -notmatch '^[a-zA-Z0-9-]+$') {
    Write-Host "El nombre del componente solo debe contener letras, números o guiones medios (-)." -ForegroundColor Red
    exit
}

# Convertir $Name a CamelCase solo para el uso dentro del template
$NameComponent = ($Name -split '-').ForEach({ $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }) -join ''

# Construir la ruta final combinando "src/components" con lo que el usuario proporcionó
$Path = Join-Path "src/components" $Path

# Verificar que la ruta no sea nula o vacía
if (-not $Path) {
    Write-Host "La variable Path está vacía o es nula." -ForegroundColor Red
    exit
}

# Verificar si la ruta no existe y crearla si es necesario
if (-not (Test-Path $Path)) {
    try {
        Write-Host "La ruta especificada ($Path) no existe. Creándola..." -ForegroundColor Yellow
        New-Item -Path $Path -ItemType Directory -Force -ErrorAction Stop
        Write-Host "Ruta creada exitosamente: $Path" -ForegroundColor Green
    }
    catch {
        Write-Host "Ocurrió un error al crear la ruta: $($_.Exception.Message)" -ForegroundColor Red
        exit
    }
}

# Ruta completa para el nuevo componente
$componentDirectory = Join-Path $Path $Name
Write-Host "La ruta completa del componente es: $componentDirectory"

try {
    # Crear el directorio del componente si no existe
    if (-Not (Test-Path $componentDirectory)) {
        Write-Host "Intentando crear el directorio: $componentDirectory" -ForegroundColor Yellow
        New-Item -Path $componentDirectory -ItemType Directory -Force -ErrorAction Stop
        Write-Host "Directorio creado exitosamente: $componentDirectory" -ForegroundColor Green
    }

    # Verificar contenido de $tsxContent antes de crear el archivo
    $tsxContent = @"
import { type $($NameComponent)Props } from "./$($Name).types";

export function $($NameComponent)(props: $($NameComponent)Props): JSX.Element {
  return (
    <div>
      <h1>$($NameComponent) component works!</h1>
    </div>
  );
}
"@

    if (-not $tsxContent) {
        Write-Host "El contenido del archivo TSX está vacío." -ForegroundColor Red
        exit
    }

    $tsxFilePath = Join-Path $componentDirectory "$Name.tsx"
    Write-Host "Intentando crear el archivo TSX en la ruta: $tsxFilePath"

    # Verificar si la ruta y el archivo están correctos antes de usar Set-Content
    if (Test-Path $tsxFilePath) {
        Write-Host "El archivo ya existe en la ruta: $tsxFilePath, será sobrescrito." -ForegroundColor Yellow
    }

    # Crear el archivo TSX del componente
    Set-Content -Path $tsxFilePath -Value $tsxContent -ErrorAction Stop
    Write-Host "Archivo TSX creado exitosamente en la ruta: $tsxFilePath" -ForegroundColor Green

    # Crear el archivo de tipos (types.ts)
    $typesContent = @"
export type $($NameComponent)Props = {
    // Define your props here
}
"@

    $typesFilePath = Join-Path $componentDirectory "$Name.types.ts"
    Set-Content -Path $typesFilePath -Value $typesContent -ErrorAction Stop

    # Crear el archivo index.ts que exporta el componente
    $indexContent = @"
export * from './$($Name)';
export * from './$($Name).types';
"@

    $indexFilePath = Join-Path $componentDirectory "index.ts"
    Set-Content -Path $indexFilePath -Value $indexContent -ErrorAction Stop

    # Actualizar o crear el archivo index.ts del directorio raíz (Path)
    $rootIndexFilePath = Join-Path $Path "index.ts"
    $exportStatement = "export * from './$($Name)';"

    # Verificar si el archivo index.ts ya existe en el directorio raíz
    if (-not (Test-Path $rootIndexFilePath)) {
        # Crear el archivo index.ts en el directorio raíz
        Set-Content -Path $rootIndexFilePath -Value $exportStatement -ErrorAction Stop
        Write-Host "Archivo index.ts creado en la ruta raíz con la exportación de $Name." -ForegroundColor Green
    } else {
        # Añadir la exportación si no existe ya en el archivo index.ts
        if (-not (Get-Content $rootIndexFilePath | Select-String -Pattern $Name)) {
            $existingContent = Get-Content $rootIndexFilePath -Raw
            $newContent = $existingContent + $exportStatement  # Añadir sin salto de línea extra
            Set-Content -Path $rootIndexFilePath -Value $newContent -ErrorAction Stop
            Write-Host "Línea export * from './$Name'; añadida al archivo index.ts en la ruta raíz." -ForegroundColor Green
        } else {
            Write-Host "La exportación ya existe en el archivo index.ts del directorio raíz." -ForegroundColor Yellow
        }
    }

    Write-Host "Todos los archivos del componente se han creado correctamente." -ForegroundColor Green
}
catch {
    Write-Host "Ocurrió un error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Detalles: $($_.Exception.StackTrace)" -ForegroundColor Yellow
}
