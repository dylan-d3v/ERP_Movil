# Fase 7 - Reportes de Ventas

## Resumen
Crear la funcionalidad de reportes de ventas con filtros por período y exportación a Excel (CSV) y PDF. El dueño de la panadería puede consultar sus ventas por día, mes, año o rango de fechas, y exportar el reporte para compartir o archivar.

---

## Filtros de período
- **Día**: ventas del día actual
- **Mes**: ventas del mes actual
- **Año**: ventas del año actual
- **Rango personalizado**: fecha inicio + fecha fin

---

## Pantalla de reportes

### Navegación
- Agregar botón o acceso a "Reportes" desde el dashboard o menú existente
- Se abre pantalla completa `ReportsScreen`

### Layout de la pantalla
- Selector de período en la parte superior (segmented button o dropdown)
- Si es rango personalizado: mostrar date pickers para inicio y fin
- Botón "Generar reporte"
- Lista de ventas filtradas debajo
- Cada venta muestra:
  - Fecha y hora
  - Lista de productos vendidos
  - Monto total
- Botones de exportar: "Exportar Excel" · "Exportar PDF"

### Estados de la pantalla
- **Vacío**: mensaje "No hay ventas en este período"
- **Cargando**: `CircularProgressIndicator`
- **Con datos**: lista + botones de exportar visibles

---

## Lógica de negocio

### Cálculo de totales
- `SalesRepository` ya tiene los métodos necesarios:
  - `getRecentSales()` para ventas recientes
  - `getSalesTotalByDateRange(start, end)` para totales
  - `getSaleWithItems(saleId)` para detalle de items
- Para filtro **día**: usar `getSalesTotalByDateRange(dayStart, dayStart+1)`
- Para filtro **mes**: usar rango primer día del mes a primer día del mes siguiente
- Para filtro **año**: usar rango primer día del año a primer día del año siguiente
- Para filtro **rango**: usar fechas seleccionadas por el usuario

### Cálculo de ganancia
- `Ganancia = Ventas del período - Egresos del período`
- Ambos se calculan con los métodos `getSalesTotalByDateRange` y `getExpensesTotalByDateRange`

---

## Exportación Excel (CSV)

### Datos a incluir
- Fecha del reporte
- Período consultado
- Lista de ventas:
  - ID de venta
  - Fecha y hora
  - Productos (nombre, cantidad, precio unitario)
  - Total de la venta
- Totales:
  - Total de ventas del período
  - Total de egresos del período
  - Ganancia del período

### Formato
- Archivo `.csv` separado por comas
- Encabezados en español
- Numeros con formato legible (dos decimales para precios)

### Implementación
- Usar paquete `csv` (agregar a pubspec.yaml)
- Generar string CSV en memoria → escribir archivo temporal → compartir

---

## Exportación PDF

### Datos a incluir
- Título: "Reporte de Ventas"
- Fecha de generación
- Período consultado
- Lista de ventas con detalle de productos
- Totales y ganancia del período

### Formato
- Documento PDF simple, tabla o lista
- Tipografía legible
- Totales destacados

### Implementación
- Usar paquete `pdf` (agregar a pubspec.yaml)
- `Printing.sharePdf()` o `Printing.savePdf()`

---

## Paquetes a agregar (pubspec.yaml)

```yaml
dependencies:
  csv: ^6.0.0
  pdf: ^3.11.0
  printing: ^5.13.0
  share_plus: ^10.0.0
  intl: ^0.19.0  # ya existe para formato de fechas
```

---

## Estructura de archivos

```
lib/
  data/
    repositories/
      sales_repository.dart   (existente — ya tiene lo necesario)
      expense_repository.dart (existente — ya tiene lo necesario)
  ui/
    screens/
      reports/
        reports_screen.dart       nueva pantalla
        reports_controller.dart   ChangeNotifier con filtros y datos
  services/
    excel_exporter.dart          generar y compartir CSV
    pdf_exporter.dart            generar y compartir PDF

Fases/
  Fase-7-Reporte-de-ventas.md
```

---

## Comportamiento esperado
- Al abrir reportes, mostrar filtro "Día" seleccionado por defecto
- Al cambiar filtro, recalcular datos automáticamente
- Al presionar "Exportar Excel", generar CSV y abrir share dialog
- Al presionar "Exportar PDF", generar PDF y abrir share dialog
- Si no hay ventas, mostrar mensaje vacío sin errores
- Los datos de ventas voided (anuladas) NO se incluyen en reportes

---

## Fuera de esta fase
- Reportes de egresos单独的
- Comparativas entre períodos
- Gráficos
- Configuración de formato de exportación
- Envío automático por email
- Historial de reportes exportados

---

## Test cases y validación
```bash
flutter analyze
flutter test
flutter run
```

### Escenarios mínimos
- reportes muestra filtros de período (día, mes, año, rango)
- reporte vacío muestra mensaje "No hay ventas en este período"
- reporte de un día muestra las ventas de ese día
- reporte de un mes muestra las ventas de ese mes
- reporte de un año muestra las ventas de ese año
- reporte de rango personalizado funciona con fechas seleccionadas
- exportar Excel genera archivo descargable
- exportar PDF genera archivo descargable
- ventas anuladas no aparecen en reportes
