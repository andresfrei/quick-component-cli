param (
    [Parameter(Mandatory = $true)]
    [string]$ComponentName
)

# Ruta base donde se crearán los componentes
$basePath = "src/components"

# Ruta completa para el nuevo componente
$componentPath = Join-Path $basePath $ComponentName

# Crear el directorio del componente
if (-Not (Test-Path $componentPath)) {
    New-Item -Path $componentPath -ItemType Directory
}

# Crear el archivo TSX del componente
$tsxContent = @"
import React from "react";
import { type ${ComponentName}Props } from './${ComponentName}.types';

export function ${ComponentName}(props: ${ComponentName}Props): JSX.Element {
  return (
    <div>
      <h1>${ComponentName} component works!</h1>
    </div>
  );
}
"@

$tsxFilePath = Join-Path $componentPath "$ComponentName.tsx"
Set-Content -Path $tsxFilePath -Value $tsxContent

# Crear el archivo de tipos (types.ts)
$typesContent = @"
export type ${ComponentName}Props {
    // Define your props here
}
"@

$typesFilePath = Join-Path $componentPath "$ComponentName.types.ts"
Set-Content -Path $typesFilePath -Value $typesContent

# Crear el archivo index.ts que exporta el componente
$indexContent = @"
export * from './$($ComponentName)';
"@

$indexFilePath = Join-Path $componentPath "index.ts"
Set-Content -Path $indexFilePath -Value $indexContent

# Actualizar el archivo barril src/components/index.ts
$barrelFilePath = Join-Path $basePath "index.ts"

# Crear el archivo barril si no existe
if (-Not (Test-Path $barrelFilePath)) {
    New-Item -Path $barrelFilePath -ItemType File
}

# Añadir la exportación del nuevo componente al archivo barril
#$exportStatement = "export * from './$($ComponentName)';"

# Verificar si la exportación ya existe para no duplicar
if (-Not (Get-Content $barrelFilePath | Select-String -Pattern $ComponentName)) {
    # Añadir un salto de línea antes de la nueva exportación
    #Add-Content -Path $barrelFilePath -Value "`r`n$exportStatement"
}

Write-Host "Component $ComponentName created successfully at $componentPath and exported in $basePath/index.ts"
