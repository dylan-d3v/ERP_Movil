# Fase 2 - Definición de Base de Datos y Repositorios Base

## Resumen
Redactar `Fases/fase_2.md` como una fase estrictamente enfocada en persistencia local: definir las tablas Drift iniciales y crear los repositorios base que encapsulan operaciones CRUD y consultas mínimas. La fase no debe agregar UI de negocio, formularios, navegación nueva, servicios de aplicación ni lógica avanzada de reportes.

La fase debe dejar la app compilando, con `app_database.dart` ya registrando las tablas reales, `app_database.g.dart` regenerado, y repositorios listos para que la siguiente fase consuma la base sin rediseñar el esquema.

## Cambios clave a especificar en `fase_2.md`
- Expandir `lib/data/database/app_database.dart` para registrar estas tablas:
  - `Products`
  - `Sales`
  - `SaleItems`
  - `Expenses`
  - `StockMovements`
- Modelar ventas como `Sales` + `SaleItems`.
  - `Sales` guarda metadatos de la venta y su estado de anulación.
  - `SaleItems` guarda cada producto vendido con cantidad y precio histórico unitario.
- Modelar inventario solo por eventos con `StockMovements`.
  - No crear tabla de stock actual en esta fase.
  - El stock disponible se obtiene sumando entradas y salidas por producto.
- Crear repositorios base en `lib/data/repositories/`:
  - `ProductRepository`
  - `SalesRepository`
  - `ExpenseRepository`
  - `StockRepository`
- Definir en el markdown el alcance exacto de cada repositorio:
  - `ProductRepository`: crear, editar, listar, obtener por id, desactivar si aplica.
  - `SalesRepository`: crear venta con detalle, listar ventas, obtener venta con ítems, anular venta.
  - `ExpenseRepository`: crear, editar, listar por fecha/rango, eliminar solo si la fase lo permite.
  - `StockRepository`: registrar movimiento, listar movimientos por producto, calcular stock actual por producto.
- Incluir regeneración obligatoria de Drift con `build_runner` y actualización de pruebas para reemplazar el `widget_test.dart` por defecto, al menos con una prueba básica que valide que la app arranca con `HomeScreen` o que la nueva base compila sin referencias rotas.

## Interfaces y reglas que el plan debe dejar cerradas
- Tablas y campos mínimos:
  - `Products`: `id`, `name`, `salePrice`, `isActive`, `createdAt`, `updatedAt`
  - `Sales`: `id`, `createdAt`, `isVoided`
  - `SaleItems`: `id`, `saleId`, `productId`, `quantity`, `unitPrice`
  - `Expenses`: `id`, `category`, `amount`, `notes` opcional, `createdAt`
  - `StockMovements`: `id`, `productId`, `type`, `quantity`, `reason`, `referenceId` opcional, `createdAt`
- Reglas de integridad:
  - No borrar ventas.
  - La anulación de ventas se representa con bandera/estado, no con delete.
  - `SaleItems.unitPrice` conserva el precio histórico.
  - El stock se calcula desde `StockMovements`.
- Alcance de consultas mínimas:
  - listado de productos activos
  - listado de ventas recientes
  - detalle de una venta con sus ítems
  - listado de egresos por rango de fechas
  - cálculo de stock actual por producto
- El markdown debe indicar explícitamente qué queda fuera:
  - dashboard
  - reportes
  - exportación
  - pantallas CRUD
  - validaciones de negocio complejas
  - servicios de ganancia
- Mantener el idioma del código en inglés y la UI en español.

## Plan de pruebas y validación que debe incluir la fase
- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze`
- `flutter test`
- `flutter run`
- Verificaciones funcionales mínimas:
  - la app sigue abriendo en `HomeScreen`
  - Drift genera `app_database.g.dart` sin errores
  - la compilación no rompe Provider ni el arranque
  - los repositorios compilan y resuelven sus imports
  - la base puede instanciarse con las nuevas tablas registradas

## Supuestos y defaults elegidos
- `Expenses.category` será texto simple en esta fase; no se creará tabla separada de categorías todavía.
- `Products` usará desactivación lógica con `isActive` en lugar de borrado físico.
- `StockMovements.type` distinguirá entrada/salida para soportar compras, ajustes y descuentos por venta más adelante.
- La anulación de una venta se manejará en la misma tabla `Sales` con `isVoided`; no se creará tabla aparte de historial de estados.
- La Fase 2 definirá estructura y repositorios base, pero no conectará todavía esos repositorios a nuevas pantallas ni a flujos de negocio visibles.
