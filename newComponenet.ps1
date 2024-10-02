param (
    [Parameter(Mandatory = $true)]
    [string]$Name,
    
    [string]$Path = "src/components"  # Parámetro opcional con valor predeterminado
)

# Ruta completa para el nuevo componente
$componentDirectory = Join-Path $Path $Name

# Crear el directorio del componente
if (-Not (Test-Path $componentDirectory)) {
    New-Item -Path $componentDirectory -ItemType Directory
}

# Crear el archivo TSX del componente
$tsxContent = @"
import React from 'react';

interface ${ComponentName}Props {
  // Define your props here
}

export const $($Name): React.FC<$($Name)Props> = ({}) => {
    return (
        <div>
            $($Name) component works!
        </div>
    );
};

"@

$tsxFilePath = Join-Path $componentDirectory "$Name.tsx"
Set-Content -Path $tsxFilePath -Value $tsxContent

# Crear el archivo de tipos (types.ts)
$typesContent = @"
export interface ${ComponentName}Props {
    // Define your props here
}
"@

$typesFilePath = Join-Path $componentDirectory "$Name.types.ts"
Set-Content -Path $typesFilePath -Value $typesContent

# Crear el archivo index.ts que exporta el componente
$indexContent = @"
export * from './$($Name)';
"@

$indexFilePath = Join-Path $componentDirectory "index.ts"
Set-Content -Path $indexFilePath -Value $indexContent

# Actualizar el archivo barril src/components/index.ts
$barrelFilePath = Join-Path $Path "index.ts"

# Crear el archivo barril si no existe
if (-Not (Test-Path $barrelFilePath)) {
    New-Item -Path $barrelFilePath -ItemType File
}

# Añadir la exportación del nuevo componente al archivo barril
$exportStatement = "export * from './$($Name)';"

# Verificar si la exportación ya existe para no duplicar
if (-Not (Get-Content $barrelFilePath | Select-String -Pattern $Name)) {
    # Añadir un salto de línea antes de la nueva exportación
    Add-Content -Path $barrelFilePath -Value "`r`n$exportStatement"
}

Write-Host "Component $Name created successfully at $componentDirectory and exported in $barrelFilePath"
