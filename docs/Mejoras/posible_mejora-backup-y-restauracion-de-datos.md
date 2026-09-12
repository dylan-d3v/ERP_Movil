# Posible mejora - Backup y restauración de datos

## Resumen
Agregar funcionalidad de backup manual de la base de datos SQLite para proteger contra pérdida de datos por daño o pérdida del dispositivo. El backup se exporta a un archivo que el usuario puede guardar en su nube personal (Google Drive, PC, etc.).

---

## Contexto

### ¿Por qué es necesario?
- La app es 100% offline y local
- Si el dispositivo se rompe o se pierde, se pierden TODOS los datos
- SQLite no se "llena" ni falla por acumulación (puede manejar años de datos), pero sí es vulnerable a:
  - Daño físico del dispositivo
  - Reinicio brusco que corrompa el archivo
  - Pérdida/robo del celular

### ¿Qué no es este feature?
- No es sincronización en la nube (no hay backend)
- No es backup automático programado (requiere acción del usuario)
- No es restauración automática

---

## Opciones de implementación

### Opción 1: Backup de archivo SQLite (recomendado)
- Copiar el archivo `panaderia_erp.db` directamente
- Ventaja: incluye TODO (datos, estructura, índices)
- Desventaja: archivo binario, necesita el mismo proceso inverso para restaurar
- El usuario guarda el `.db` en su Google Drive o PC

### Opción 2: Exportación JSON
- Exportar todos los datos a un archivo JSON legible
- Ventaja: legible, portable, abre en cualquier editor
- Desventaja: no incluye relaciones complejas ni estructura de la DB
- Solo sirve como referencia, no como restauración completa

### Opción 3: Exportación CSV por tabla
- Exportar cada tabla (Products, Sales, SaleItems, Expenses, StockMovements) a su propio CSV
- Ventaja: abre en Excel, fácil de revisar
- Desventaja: múltiples archivos, pierde relaciones

---

## Propuesta elegida: Opción 1 (Backup de archivo SQLite)

### Por qué
- Es el método más simple y completo
- No requiere transformar datos
- El usuario solo necesita copiar un archivo a su nube

### Limitación
- Para restaurar, el usuario debería colocar el archivo de vuelta en el directorio de documentos
- Esto requiere un proceso manual y conocimiento básico de archivos Android

---

## Estructura de archivos

```
lib/
  services/
    backup_service.dart    nueva clase para manejar backup/restauración
```

### BackupService
- `createBackup()` → genera una copia del archivo `.db` y abre share dialog
- `getBackupFilePath()` → retorna la ruta del archivo de base de datos
- `getBackupFileName()` → retorna nombre con fecha: `panaderia_backup_YYYYMMDD.db`

### Pantalla de configuración o menú
- Nueva opción "Backup" en algún lugar accesible (ej: menú de ajustes o dashboard)
- Botón "Crear Backup" que ejecuta `BackupService.createBackup()`
- Muestra confirmación al usuario antes de compartir

---

## Cómo ver el archivo .db gráficamente (sin código)

### DB Browser for SQLite

1. **Descarga** DB Browser desde https://sqlitebrowser.org/
2. **Instala** la versión para Windows (o Mac/Linux según tu PC)
3. **Copia el archivo** `panaderia_erp.db` desde el celular a tu PC
   - Conecta el celular por USB
   - Navega a la carpeta de documentos de la app (o comparte el archivo por email/WhatsApp a ti mismo)
4. **Abre el archivo** en DB Browser:
   - Ejecuta DB Browser
   - Click "Open Database"
   - Selecciona el archivo `.db`
5. **Explora los datos:**
   - Pestaña "Browse Data" → ver contenido de cada tabla
   - Pestaña "Execute SQL" → escribir consultas SQL
   - Pestaña "Database Structure" → ver estructura de tablas

### Qué verás en cada tabla

| Tabla | Qué contiene |
|-------|---------------|
| Products | id, name, price, stock, etc. |
| Sales | id, total, createdAt, isVoided |
| SaleItems | id, saleId, productId, quantity, unitPrice |
| Expenses | id, description, amount, createdAt, category |
| StockMovements | id, productId, quantity, type, createdAt |

### Para qué sirve en la práctica
- Verificar que el backup quedó bien antes de guardarlo en la nube
- Revisar datos específicos sin abrir la app
- Hacer consultas rápidas que la app no muestra (ej: "¿cuánto vendí de pan francés en enero?")

---

## FUERA DE ESTE ALCANCE
- Restauración automática de backup
- Backup automático programado
- Sincronización a la nube
- múltiples perfiles de usuario
- importación de datos desde JSON/CSV (solo exportación)

---

## Consideraciones técnicas
- Usar `path_provider` para obtener el directorio de documentos
- Usar `share_plus` para abrir el diálogo de compartir
- El archivo `.db` puede ser de varios MB si hay muchos años de datos
- El nombre del archivo incluye fecha para identificar fácilmente cuál backup es el más reciente

---

## Test cases
```bash
flutter analyze
flutter test
```

### Escenarios mínimos
- el botón "Crear Backup" aparece en la UI
- al presionar "Crear Backup" se genera un archivo con extensión `.db`
- se abre el diálogo de compartir del sistema
- el archivo compartido puede guardarse en Google Drive o memoria interna