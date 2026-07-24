# Multi-Client Directory & IT Service Structure Generator

Este script de **PowerShell** automatiza la creación de una estructura estandarizada de carpetas, documentación inicial y plantillas operativas de IT Service Management (ITSM) para múltiples clientes (`CUST_1`, `CUST_2`, etc.).

Está optimizado para entornos de soporte informático, infraestructura multi-cliente y administración de paisajes **SAP / MGW / RISE**.

---

## 📋 Características

* **Estructura Multi-Cliente:** Genera un árbol de directorios idéntico para cada cliente definido.
* **Gobierno e ITSM Estandarizado:** Crea subcarpetas organizadas numéricamente desde Gobernanza (`00`) hasta Plantillas (`09`).
* **Plantillas de Documentación Automatizadas:** Genera automáticamente plantillas esenciales en formato Markdown dentro de la carpeta `09_Templates`:
  * `Incident_Template.md`
  * `RCA_Template.md` (Root Cause Analysis)
  * `Change_Request_Template.md`
  * `SOP_Template.md` (Standard Operating Procedure)
* **READMEs Automatizados:** Inyecta un archivo `README.md` guía con marca de tiempo en las carpetas principales de arquitectura, gobierno, operaciones e incidentes.
* **Seguro e Idempotente:** Utiliza el parámetro `-Force` y validaciones con `Test-Path` para evitar sobrescribir carpetas o archivos existentes no deseados.

---

## 📂 Estructura de Directorios Generada

Por cada cliente configurado, se creará la siguiente jerarquía:

```text
The DIR/
└── <CLIENT_NAME>/
    ├── 00_Governance/              # SLA, Contratos, Matriz RACI
    ├── 01_Architecture/            # Diagramas SAP, Redes, Nube, SO (Linux/Windows)
    ├── 02_Environments/            # Detalles de PROD, QA y DEV
    ├── 03_Operations/              # Runbooks, SOPs, Monitoreo y Health Checks
    ├── 04_Incidents_Problems/      # Registro de Incidentes (INC) y Problemas (PRB)
    ├── 05_Changes_Releases/        # CAB, Órdenes de Transporte y Entregas
    ├── 06_Projects/                # Proyectos Activos y Completados
    ├── 07_Vendors_MGW_RISE/        # Tickets de proveedores (MGW / SAP RISE)
    ├── 08_Backups_Dumps/           # Respaldos de SAP, Base de Datos y SO
    └── 09_Templates/               # Plantillas Markdown (.md) predefinidas
```

---

## ⚙️ Configuración y Requisitos

### Requisitos Previos
* **PowerShell 5.1** o superior (compatible con PowerShell Core 7+ en Windows, Linux y macOS).

### Personalización
Abre el script `.ps1` en tu editor preferido y ajusta la sección de configuración inicial si deseas usar valores fijos por defecto:

```powershell
# Ruta raíz donde se creará la estructura
$basePath = "C:\Ruta\A\Tu\Directorio" 

# Lista de códigos o nombres de tus clientes
$clients = @("CLIENTE_A", "CLIENTE_B", "CLIENTE_C")
```

---

## 🚀 Uso y Ejecución

### Ejecución Básica
Para ejecutar el script utilizando los valores predeterminados dentro de la sección `# CONFIGURATION`:

```powershell
.\Set_UP_Customer_Folder.ps1
```

### Ejecución por Parámetros CLI (Avanzado)
Si adaptas el script para recibir parámetros de línea de comandos mediante el bloque `param()`, puedes invocarlo dinámicamente sin modificar el código fuente:

```powershell
# Ejecución pasando ruta y un único cliente
.\Set_UP_Customer_Folder.ps1 -BasePath "D:\ClientsData" -Clients "CUST_99"

# Ejecución pasando múltiples clientes
.\Set_UP_Customer_Folder.ps1 -BasePath "D:\ClientsData" -Clients "CUST_01", "CUST_02", "CUST_03"
```

---

## 📄 Plantillas Incluidas

En la carpeta `09_Templates` de cada cliente se incluirán los siguientes archivos listos para usar:

| Plantilla | Propósito |
| :--- | :--- |
| **`Incident_Template.md`** | Registro simplificado de incidentes operacionales, impacto y resolución. |
| **`RCA_Template.md`** | Análisis de Causa Raíz con línea de tiempo y acciones correctivas/preventivas. |
| **`Change_Request_Template.md`** | Formulario para solicitudes de cambios (RFC) con nivel de riesgo y plan de rollback. |
| **`SOP_Template.md`** | Estructura estandarizada para Procedimientos Operativos Estándar. |

---

## 🔧 Solución de Problemas (Troubleshooting)

### 1. Error de Política de Ejecución (`ExecutionPolicy`)
**Síntoma:**
```text
File Set_UP_Customer_Folder.ps1 cannot be loaded because running scripts is disabled on this system.
```
**Solución:**
Permite la ejecución de scripts en tu sesión actual de PowerShell corriendo:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

### 2. Permisos Denegados / Acceso Denegado
**Síntoma:**
```text
New-Item : Access to the path '...' is denied.
```
**Solución:**
* Asegúrate de que la ruta asignada a `$basePath` exista o tengas permisos de escritura en el volumen de disco destino.
* Ejecuta la consola de PowerShell como **Administrador** si intentas escribir en directorios del sistema (ej. `C:\Program Files` o raíces de disco del sistema).

### 3. Rutas de Archivo Demasiado Largas (MAX_PATH en Windows)
**Síntoma:**
PowerShell genera errores al crear subcarpetas anidadas de nivel profundo.  
**Solución:**
* Procura mantener una ruta corta en `$basePath` (por ejemplo, `C:\Ops\Clients` en lugar de carpetas muy anidadas).
* En Windows 10/11 o Windows Server 2016+, habilita el soporte de **Long Paths** mediante el Registro o Directiva de Grupo (`Enable Long Paths`).

### 4. Caracteres Especiales o Diacríticos en los Nombres
**Síntoma:**
Nombres de clientes o carpetas muestran caracteres extraños.  
**Solución:**
Guarda el archivo del script `.ps1` utilizando codificación **UTF-8 con BOM** (UTF-8 with Signature) desde VS Code u otro editor de código.
