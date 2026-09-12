# Mejora - Mostrar nombre del producto en PDF

## Resumen
El PDF exportado actualmente muestra el ID del producto en la tabla de detalle de venta (ej: "1", "2") en vez del nombre real (ej: "Pan integral", "Baguette"). Esto ocurre porque `_getProductName` en `pdf_exporter.dart` solo retorna `item.productId.toString()`.

Esta mejora es análoga a la corrección hecha en la pantalla de reportes (`Mostrar-nombre-de-producto-en-detalles-de-reporte.md`), pero aplicada al PDF exportado.

---

## Problema
En `pdf_exporter.dart`, línea 215-217:
```dart
String _getProductName(SaleItem item) {
  return item.productId.toString();
}
```
Esto solo retorna el ID, no el nombre del producto.

---

## Solución

### pdf_exporter.dart
- Modificar `export()` para recibir `Map<int, String> productNames` como parámetro
- Actualizar `_getProductName(SaleItem item)` para buscar en el map:
  ```dart
  String _getProductName(SaleItem item, Map<int, String> productNames) {
    return productNames[item.productId] ?? 'Producto #${item.productId}';
  }
  ```
- Actualizar todas las llamadas a `_getProductName` para pasar el map

### reports_controller.dart
- En `loadReport()`, después de cargar las ventas, cargar todos los `Product` y crear un `Map<int, String>` con `id -> name`
- Pasar `productNames` al llamar `PdfExporter().export(report, productNames)`

---

## Estructura de cambios

```
lib/
  services/
    pdf_exporter.dart      - modificar export() y _getProductName()
  ui/
    screens/
      reports/
        reports_controller.dart   - cargar productNames en loadReport()
```

---

## Comportamiento esperado
- Al exportar PDF, la columna "Producto" muestra el nombre real (ej: "Pan integral")
- Si un producto no existe en el map, muestra fallback `Producto #N`
- No afecta otros formatos de exportación (CSV ya muestra nombres correctamente)

---

## Test cases
```bash
flutter analyze
flutter test
flutter run
```

### Escenarios mínimos
- exportar PDF muestra nombre del producto en vez de ID
- fallback funciona si el producto no tiene nombre resuelto