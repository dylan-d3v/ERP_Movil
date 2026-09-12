# Mejora - Presentacion visual del Excel de reportes

## Resumen
Mejorar la exportacion de Excel de reportes de ventas para generar un archivo `.xlsx` real con estilos visuales. El objetivo es mantener los mismos datos del reporte, pero presentar tablas con colores, bordes, encabezados destacados y secciones claras para que el archivo sea mas comodo de revisar.

La mejora reemplaza el archivo `.csv` anterior porque CSV no soporta colores ni estilos reales.

## Cambios clave
- Cambiar `ExcelExporter` para generar `.xlsx` en vez de `.csv`.
- Usar el paquete `excel` para construir workbook, hoja, celdas, estilos, bordes y anchos de columna.
- Mantener el boton actual `Exportar Excel` y el flujo de compartir con `share_plus`.
- Mantener los mismos datos:
  - titulo del reporte.
  - fecha de generacion.
  - periodo consultado.
  - detalle de ventas.
  - productos, cantidades, precios, subtotales y total por venta.
  - resumen del periodo con ventas, egresos y ganancia.

## Estilo visual esperado
- Titulo principal con fondo destacado y texto en negrita.
- Encabezados de tabla con color de fondo, texto en negrita y bordes.
- Filas de detalle con bordes para que se entiendan como tabla.
- Fila de total por venta destacada con un color suave.
- Seccion `Resumen del Periodo` separada y con encabezado propio.
- Totales finales con colores coherentes:
  - ventas en verde.
  - egresos en rojo.
  - ganancia en verde si es positiva y rojo si es negativa.
- Columnas con anchos ajustados para mejorar lectura en Excel movil o escritorio.
- Archivo generado con nombre `reporte_ventas_YYYYMMDD_HHmmss.xlsx`.

## Cambios tecnicos esperados
- Actualizar `pubspec.yaml` para usar `excel`.
- Refactorizar `lib/services/excel_exporter.dart` para construir un `.xlsx` estilizado.
- Conservar `ReportData` sin cambios para no afectar PDF ni reportes.
- No modificar filtros, calculos, ventas anuladas ni nombres de productos.
- No modificar `ReportsController` salvo que sea necesario para mantener el flujo de exportacion.

## Test cases y validacion
- El humano ejecuta manualmente:
  - `flutter analyze`
  - `flutter test`
  - `flutter run`
- Escenarios minimos:
  - `Exportar Excel` genera un archivo `.xlsx`.
  - El archivo se comparte correctamente desde Android.
  - El Excel conserva todos los datos que tenia el CSV.
  - La tabla de ventas muestra encabezados con color y bordes.
  - Los totales por venta aparecen visualmente destacados.
  - El resumen del periodo muestra ventas, egresos y ganancia con colores.
  - El PDF no cambia.
  - Los reportes siguen excluyendo ventas anuladas.

## Supuestos
- La mejora es visual y de formato de exportacion, no de datos.
- Se acepta cambiar de `.csv` a `.xlsx` para permitir colores reales.
- Los comandos `dart` y `flutter` se ejecutan manualmente por el humano.
