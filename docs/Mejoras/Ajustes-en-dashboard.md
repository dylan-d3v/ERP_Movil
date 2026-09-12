# Ajustes visuales y métricos del Dashboard y stock visible

## Resumen
Crear una fase de mejora enfocada en dos frentes ya existentes: presentación del stock y enriquecimiento del dashboard. El objetivo es hacer más legible el inventario y convertir el dashboard en un resumen mensual y diario más claro, sin abrir todavía reportes ni filtros avanzados.

La implementación no debe cambiar la lógica base de ventas, egresos o stock por eventos; solo debe ajustar cálculos agregados del dashboard y formato visual/numérico en los módulos donde hoy ya aparece el stock.

## Cambios clave
- Mostrar el stock como número entero en todos los módulos donde hoy aparece:
  - `Dashboard`
  - `Productos`
  - `Ventas`
- El stock no debe renderizarse con decimales visibles.
  - Ejemplo: `5` en lugar de `5.00`
- En la lista de stock bajo del dashboard:
  - si el stock es `0`, destacar visualmente ese producto en rojo
  - el texto del stock también debe reflejar ese estado crítico
- Ampliar el dashboard con dos tarjetas nuevas:
  - `Ganancia del mes`
  - `Egresos del mes`
- Las tarjetas mensuales deben indicar explícitamente el mes actual en el texto visible.
  - Ejemplo esperado: `Ventas de abril`, `Egresos de abril`, `Ganancia de abril`
- Los valores mensuales deben calcularse solo dentro del mes calendario actual y reiniciarse automáticamente al cambiar de mes, usando el rango `primer día del mes actual` a `primer día del mes siguiente`.

## Comportamiento esperado
- El stock visible en `Productos` debe verse como entero:
  - `Stock actual: 5`
- El stock visible en `Ventas` debe verse como entero:
  - `Stock disponible: 5`
- El stock visible en `Dashboard` debe verse como entero:
  - `Stock: 5`
- En `Dashboard`, si un producto tiene stock `0`:
  - la tarjeta o fila del producto debe usar rojo como color de alerta
  - el texto del stock debe ser claramente más notorio que el resto
- En las tarjetas del dashboard:
  - `Ganancia del dia` en verde si es positiva
  - `Ganancia del dia` en rojo si es negativa
  - `Ganancia del mes` en verde si es positiva
  - `Ganancia del mes` en rojo si es negativa
  - `Egresos del dia` siempre en rojo
  - `Egresos del mes` siempre en rojo
- `Ingresos del dia` y `Ventas del mes` pueden conservar estilo neutro o positivo consistente, pero no deben contradecir el sistema visual de ganancias/egresos.
- Si no hay datos, los valores del dashboard siguen mostrando `0.00` en montos y lista vacía o normal para stock bajo.

## Cambios técnicos esperados
- Extender `DashboardController` para calcular:
  - `monthExpenses` 
  - `monthProfit`
  - nombre del mes actual para UI
- Reutilizar:
  - `SalesRepository.getSalesTotalByDateRange(...)`
  - `ExpenseRepository.getExpensesTotalByDateRange(...)`
- No crear tablas nuevas ni persistencia adicional.
- Añadir un helper visual o formatter simple para mostrar stock como entero.
  - Puede ser una función compartida mínima o helper local en cada pantalla si se mantiene compacto.
- Ajustar `dashboard_screen.dart` para:
  - agregar dos tarjetas nuevas
  - aplicar color condicional a métricas
  - aplicar color rojo a productos con stock `0`
  - mostrar etiquetas mensuales con el mes actual
- Ajustar `home_screen.dart` y `sales_screen.dart` para dejar de usar `toStringAsFixed(2)` en stock y pasar a entero visible.

## Test cases y validación
- `flutter analyze`
- `flutter test`
- `flutter run`
- Escenarios mínimos:
  - el stock se muestra sin decimales en `Productos`
  - el stock se muestra sin decimales en `Ventas`
  - el stock se muestra sin decimales en `Dashboard`
  - un producto con stock `0` aparece resaltado en rojo en stock bajo
  - el dashboard muestra `Egresos del mes`
  - el dashboard muestra `Ganancia del mes`
  - las tarjetas mensuales muestran el mes actual en el texto
  - `Ganancia del dia` cambia a rojo si el valor es negativo
  - `Ganancia del mes` cambia a rojo si el valor es negativo
  - `Egresos del dia` y `Egresos del mes` se muestran en rojo
  - los cálculos mensuales se basan solo en el mes actual

## Supuestos
- El stock seguirá guardándose y calculándose como `double`; solo cambia su presentación visual a entero.
- Para mostrar stock entero, se truncará o redondeará de forma consistente en UI; recomendado: `round()` solo si siempre manejas cantidades enteras de inventario en la práctica. Si quieres evitar ambigüedad, usar `toInt()` visualmente cuando el flujo ya opera con cantidades enteras.
- El nombre del mes actual se mostrará en español.
- Esta mejora sigue siendo parte del dashboard y presentación; no introduce reportes, configuración ni nuevas acciones de negocio.
