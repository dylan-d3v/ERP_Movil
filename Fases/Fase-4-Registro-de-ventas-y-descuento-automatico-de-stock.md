# Fase 4 - Registro de Ventas con Descuento Automatico de Stock

## Resumen
Redactar `Fases/Fase-4-Registro-de-ventas-y-descuento-automatico-de-stock.md` como la fase enfocada en el primer flujo transaccional completo de la app: registrar ventas con uno o varios productos, calcular total y descontar stock automaticamente usando la base creada en Fase 2 y la gestion de productos/stock creada en Fase 3.

La fase debe introducir una navegacion minima con tabs simples para convivir con el modulo de productos ya existente. No debe incluir todavia dashboard, reportes, exportacion, egresos visibles ni historial complejo de ventas.

## Cambios clave
- Agregar navegacion basica con dos tabs:
  - `Productos`
  - `Ventas`
- Mantener el modulo de productos existente funcional, sin redisenarlo.
- Crear el modulo visible de ventas con una pantalla completa que permita:
  - seleccionar uno o varios productos activos
  - ingresar cantidad por producto
  - ver precio unitario actual del producto
  - calcular subtotal por linea
  - calcular total general de la venta
  - confirmar y guardar la venta
- Usar `SalesRepository`, `ProductRepository` y `StockRepository` existentes.
- Al guardar una venta:
  - crear un registro en `Sales`
  - crear las lineas en `SaleItems`
  - registrar movimientos de stock de salida por cada producto vendido
- Mostrar feedback claro en UI cuando la venta se guarda correctamente.
- No incluir todavia anulacion de ventas desde la UI, aunque el repositorio ya la soporte.

## Interfaces y comportamiento esperado
- La tab de ventas debe mostrar estado vacio si no hay productos activos.
  - Mensaje claro indicando que primero se deben crear productos.
- La pantalla de ventas debe permitir agregar multiples lineas.
- Cada linea debe pedir:
  - producto
  - cantidad
- El precio unitario debe tomarse del `salePrice` actual del producto al momento de registrar la venta.
- El total visible debe actualizarse cuando cambien productos o cantidades.
- Validaciones minimas:
  - debe existir al menos una linea valida
  - cada linea debe tener producto seleccionado
  - la cantidad debe ser mayor a cero
  - no permitir productos repetidos en la misma venta
  - no permitir confirmar si algun producto no tiene stock suficiente
- Antes de guardar, validar stock disponible por producto calculado desde movimientos.
- Al guardar:
  - limpiar el formulario
  - refrescar la vista de productos para reflejar el nuevo stock
  - mantener al usuario en la tab de ventas con confirmacion visible
- Mantener UI en espanol y codigo en ingles.

## Fuera de esta fase
- anular ventas desde la interfaz
- listado/historial completo de ventas
- detalle expandido de venta guardada
- edicion de ventas
- egresos visibles
- dashboard
- reportes
- exportacion
- calculo de ganancias

## Cambios tecnicos esperados
- Introducir una estructura simple de navegacion principal, preferiblemente con `BottomNavigationBar` o `NavigationBar`, sin convertir la app en navegacion compleja.
- Crear un controller o notifier especifico para ventas con `ChangeNotifier` + `Provider`.
- Anadir modelos UI minimos para lineas de venta en memoria, sin persistencia extra.
- Anadir consultas auxiliares si hace falta:
  - productos activos para selector de ventas
  - stock actual por producto para validar disponibilidad
- Reutilizar el modulo de productos tal como esta y conectar su refresco tras una venta exitosa.

## Plan de pruebas y validacion
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze`
- `flutter test`
- `flutter run`
- Escenarios minimos:
  - la app muestra tabs simples para `Productos` y `Ventas`
  - si no hay productos activos, ventas muestra estado vacio
  - se puede agregar una linea de venta con producto y cantidad
  - se pueden agregar varias lineas con productos distintos
  - el total se calcula correctamente
  - no se permite confirmar con cantidad invalida
  - no se permite confirmar cuando el stock no alcanza
  - al guardar una venta, el stock baja en la tab de productos
  - la venta queda registrada sin errores en la base

## Supuestos y defaults
- Fase 4 sera la primera fase con navegacion basica entre modulos, pero solo para `Productos` y `Ventas`.
- La venta usara el precio actual del producto al momento de confirmar y ese valor se guardara como precio historico en `SaleItems.unitPrice`.
- No se agregara historial visible de ventas en esta fase; la prioridad es el flujo de registro correcto.
- La validacion de stock sera obligatoria antes de guardar para evitar inventario negativo en la UI.
