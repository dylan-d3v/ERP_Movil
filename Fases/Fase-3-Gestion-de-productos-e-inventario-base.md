# Fase 3 - Gestion de Productos e Inventario Base

## Resumen
Redactar `Fases/Fase-3-Gestion-de-productos-e-inventario-base.md` como la primera fase visible para el usuario, enfocada en gestionar productos y realizar ajustes manuales de stock sobre la base de datos ya creada en Fase 2.

La fase debe dejar una pantalla funcional completa, sin adelantar ventas, egresos, dashboard ni reportes. El objetivo es que el usuario pueda crear productos, editarlos, desactivarlos, ver su stock actual calculado desde movimientos y registrar ajustes manuales de inventario.

## Cambios clave
- Reemplazar `HomeScreen` por una pantalla de gestion de productos e inventario con:
  - listado de productos activos
  - nombre, precio de venta y stock actual visible por producto
  - accion para crear producto
  - accion para editar producto
  - accion para desactivar producto
  - accion para registrar ajuste manual de stock
- Crear el flujo UI completo del modulo en `ui/screens/home` o en un modulo equivalente de productos, reutilizando la pantalla inicial como entrada principal de la app.
- Usar `Provider` para inyectar los repositorios necesarios desde la app:
  - `ProductRepository`
  - `StockRepository`
- Calcular el stock actual desde `StockMovements`; no crear tabla de stock persistido.
- Registrar ajustes manuales de inventario como movimientos de stock:
  - incremento: `type = entry`, `reason = adjustment`
  - disminucion: `type = exit`, `reason = adjustment`
- Mantener la edicion de producto limitada a los campos ya existentes en la base:
  - `name`
  - `salePrice`
  - `isActive`

## Interfaces y comportamiento esperado
- La pantalla principal debe mostrar estado vacio si no hay productos registrados.
- El formulario de producto debe permitir:
  - crear producto nuevo
  - editar producto existente
  - validar nombre no vacio
  - validar precio mayor a cero
- La accion de desactivar no debe borrar el producto; debe actualizar `isActive = false`.
- La accion de ajuste manual de stock debe pedir:
  - producto
  - tipo de ajuste: entrada o salida
  - cantidad
- La cantidad del ajuste debe ser mayor a cero.
- El stock mostrado en pantalla debe refrescarse tras crear, editar, desactivar o ajustar.
- La UI sigue en espanol y el codigo sigue en ingles.

## Fuera de esta fase
- registrar ventas
- registrar egresos
- navegacion multipantalla completa
- dashboard
- reportes
- exportacion
- calculo de ganancias
- historial detallado de movimientos en una pantalla separada

## Plan de pruebas y validacion
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze`
- `flutter test`
- `flutter run`
- Escenarios minimos:
  - la app abre en la nueva pantalla de productos
  - se puede crear un producto y verlo en el listado
  - se puede editar nombre y precio de un producto
  - se puede desactivar un producto y deja de mostrarse en activos
  - se puede registrar una entrada manual y el stock aumenta
  - se puede registrar una salida manual y el stock disminuye
  - el stock visible coincide con la suma de movimientos

## Supuestos y defaults
- Fase 3 sera un solo modulo visible y completo: productos + ajuste manual de stock.
- No se agregaran nuevos campos de producto en esta fase.
- No se agregara navegacion extra salvo la necesaria para dialogs, bottom sheets o formularios de esta pantalla.
- Si hace falta una capa minima de estado para refrescar la UI, se implementara con `ChangeNotifier` + `Provider`, sin introducir otro gestor de estado.
