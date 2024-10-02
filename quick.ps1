param (
    [Parameter(Mandatory = $true)]
    [string]$Name,
    
    [string]$Path = "src/components"  # Parámetro opcional con valor predeterminado
)

# Validar que el nombre del componente no contenga caracteres no válidos
if ($Name -match '\s|\W') {
    Write-Host "El nombre del componente no debe contener espacios ni caracteres especiales." -ForegroundColor Red
    exit
}

# Ruta completa para el nuevo componente
$componentDirectory = Join-Path $Path $Name

try {
    # Crear el directorio del componente
    if (-Not (Test-Path $componentDirectory)) {
        New-Item -Path $componentDirectory -ItemType Directory -ErrorAction Stop
    }

    # Crear el archivo TSX del componente
    $tsxContent = @"
import { type $($Name)Props } from "./$($Name).types";

export function $($Name)(props: $($Name)Props): JSX.Element {
  return (
    <div>
      <h1>$($Name) component works!</h1>
    </div>
  );
}
"@

    $tsxFilePath = Join-Path $componentDirectory "$Name.tsx"
    Set-Content -Path $tsxFilePath -Value $tsxContent -ErrorAction Stop

    # Crear el archivo de tipos (types.ts)
    $typesContent = @"
export type $($Name)Props = {
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

    # Actualizar el archivo barril (index.ts) del componente
    $barrelFilePath = Join-Path $Path "index.ts"

    # Crear el archivo barril si no existe
    if (-Not (Test-Path $barrelFilePath)) {
        New-Item -Path $barrelFilePath -ItemType File -ErrorAction Stop
    }

    # Añadir la exportación del nuevo componente al archivo barril sin salto de línea extra
    $exportStatement = "export * from './$($Name)';"

    # Verificar si la exportación ya existe para no duplicar
    if (-Not (Get-Content $barrelFilePath | Select-String -Pattern $Name)) {
        $existingContent = Get-Content $barrelFilePath -Raw
        $newContent = $existingContent.TrimEnd() + "`n" + $exportStatement
        Set-Content -Path $barrelFilePath -Value $newContent -ErrorAction Stop
    }

    Write-Host "Componente $Name creado exitosamente en $componentDirectory y exportado en $barrelFilePath" -ForegroundColor Green
}
catch {
    Write-Host "Ocurrió un error: $($_.Exception.Message)" -ForegroundColor Red
}
