# QuickComponentCLI

**QuickComponentCLI** es una herramienta de línea de comandos diseñada para simplificar y agilizar la creación de componentes en proyectos de React. Con un solo comando, puedes generar automáticamente la estructura básica de un nuevo componente, incluyendo archivos `.tsx`, tipos y la actualización del archivo de barril.

## Características

- **Generación Rápida:** Crea automáticamente archivos `.tsx`, `types.ts` y actualiza el archivo de barril `index.ts` de tu componente.
- **Configuración Personalizable:** Ajusta la plantilla del componente según tus necesidades.
- **Facilita el Flujo de Trabajo:** Reduce el tiempo de configuración de nuevos componentes, permitiendo a los desarrolladores centrarse en la lógica y el diseño.

## Requisitos

- PowerShell (versión 5.1 o superior)
- Node.js y npm (opcional, para proyectos de React)

## Ejemplo de uso:
```bash
.\NewComponent.ps1 -ComponentName NombreDelComponente
```
```bash
src/components/MyNewComponent/
│
├── MyNewComponent.tsx
├── MyNewComponent.types.ts
└── index.ts
```

```bash
src/components/index.ts:

export * from "./MyNewComponent";
```

