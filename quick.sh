#!/bin/bash

# Parámetros obligatorios y opcionales
Name="$1"
Path="${2:-src/components}"  # Si no se especifica, se usa "src/components" por defecto

# Validar que el nombre del componente no contenga espacios ni caracteres especiales
if [[ "$Name" =~ [[:space:]] || "$Name" =~ [^a-zA-Z0-9_] ]]; then
    echo "El nombre del componente no debe contener espacios ni caracteres especiales." >&2
    exit 1
fi

# Ruta completa para el nuevo componente
componentDirectory="$Path/$Name"

# Crear el directorio del componente si no existe
if [ ! -d "$componentDirectory" ]; then
    mkdir -p "$componentDirectory" || { echo "Error al crear el directorio del componente."; exit 1; }
fi

# Crear el archivo TSX del componente
tsxContent="import { type ${Name}Props } from \"./${Name}.types\";

export function ${Name}(props: ${Name}Props): JSX.Element {
  return (
    <div>
      <h1>${Name} component works!</h1>
    </div>
  );
}"

echo "$tsxContent" > "$componentDirectory/$Name.tsx" || { echo "Error al crear el archivo $Name.tsx"; exit 1; }

# Crear el archivo de tipos (types.ts)
typesContent="export type ${Name}Props = {
    // Define your props here
};"

echo "$typesContent" > "$componentDirectory/$Name.types.ts" || { echo "Error al crear el archivo $Name.types.ts"; exit 1; }

# Crear el archivo index.ts que exporta el componente
indexContent="export * from './${Name}';
export * from './${Name}.types';"

echo "$indexContent" > "$componentDirectory/index.ts" || { echo "Error al crear el archivo index.ts"; exit 1; }

# Actualizar el archivo barril (index.ts) del componente
barrelFilePath="$Path/index.ts"

# Crear el archivo barril si no existe
if [ ! -f "$barrelFilePath" ]; then
    touch "$barrelFilePath" || { echo "Error al crear el archivo barril"; exit 1; }
fi

# Añadir la exportación del nuevo componente al archivo barril sin salto de línea extra
exportStatement="export * from './${Name}';"

if ! grep -q "$Name" "$barrelFilePath"; then
    # Quitar saltos de línea adicionales antes de agregar la nueva exportación
    existingContent=$(cat "$barrelFilePath" | sed '/^$/d')
    echo -e "$existingContent\n$exportStatement" > "$barrelFilePath" || { echo "Error al actualizar el archivo barril"; exit 1; }
fi

echo "Componente $Name creado exitosamente en $componentDirectory y exportado en $barrelFilePath"
