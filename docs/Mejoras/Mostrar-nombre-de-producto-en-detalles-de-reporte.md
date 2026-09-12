# Mostrar nombre de producto en detalles de reporte

## Resumen
En la pantalla de reportes, al expandir una venta en el detalle (`_SaleCard`), los items muestran "Producto #N" en vez del nombre real del producto. Esto se debe a que no se resuelve el nombre del producto desde el repositorio.

---

## Problema
`_SaleCard` usa `_getProductName(item)` que solo retorna `item.productId.toString()`, sin consultar el nombre real.

---

## Solución
Agregar un `Map<int, String> _productNames` en `ReportsController` que se llena durante `loadReport()`. `_SaleCard` recibe este map y lo usa para mostrar el nombre real, con fallback a `Producto #N`.

---

## Cambios

### ReportsController
- Agregar campo `Map<int, String> _productNames = {}`
- En `loadReport()`, después de cargar las ventas, iterar los `saleWithItems.items` y para cada `productId` consultar `ProductRepository.getProductById()` — agrupar en un solo batch para evitar N+1
- Agregar getter `productNames` público

### ReportsScreen
- `_SaleCard` recibe `Map<int, String> productNames` como parámetro
- `_SaleCard._getProductName` retorna `productNames[item.productId] ?? 'Producto #${item.productId}'`
- `_ReportContent` pasa `controller.productNames` a cada `_SaleCard`

---

## Comportamiento esperado
- Al expandir una venta, los items muestran el nombre real del producto (ej: "Pan integral")
- Si por alguna razón el nombre no existe, muestra fallback `Producto #N`

---

## Test cases
```bash
flutter analyze
flutter test
flutter run
```

- reporte muestra nombre real del producto al expandir venta
- fallback funciona si el producto no tiene nombre resuelto

---

## Supuestos
- No se modifica la lógica de carga del reporte, solo se enriquece con los nombres
- El nombre del producto se resuelve async pero no bloquea la UI