# Fase 6 - Dashboard Base de Resumen Operativo

## Resumen
Redactar `Fases/Fase-6-Dashboard-base-de-resumen-operativo.md` como la fase enfocada en construir el primer dashboard util de la app, aprovechando que ya existen productos, ventas y egresos visibles. El objetivo es mostrar un resumen operativo claro para el dueno, sin entrar todavia en reportes avanzados ni exportacion.

La fase debe agregar una nueva tab `Dashboard` y mostrar las metricas clave definidas en el contexto del proyecto: ingresos del dia, egresos del dia, ganancia del dia, ventas del mes y productos con stock bajo.

## Cambios clave
- Agregar una nueva tab en la navegacion principal:
  - `Dashboard`
- Mantener funcionales las tabs existentes:
  - `Productos`
  - `Ventas`
  - `Egresos`
- Crear un modulo visible de dashboard con una pantalla completa que muestre:
  - ingresos del dia
  - egresos del dia
  - ganancia del dia
  - ventas del mes
  - productos con stock bajo
- Calcular todas las metricas desde la base de datos actual.
- No persistir resultados del dashboard; todo debe calcularse al consultar.

## Interfaces y comportamiento esperado
- La pantalla de dashboard debe mostrarse aunque todavia no existan ventas o egresos.
- Si no hay datos, las metricas deben mostrarse en cero y la lista de stock bajo vacia.
- El dashboard debe incluir tarjetas o bloques visibles para cada indicador:
  - `Ingresos del dia`
  - `Egresos del dia`
  - `Ganancia del dia`
  - `Ventas del mes`
- La seccion de stock bajo debe listar productos activos con stock menor o igual a un umbral fijo para esta fase.
- Default propuesto para stock bajo:
  - `<= 5`
- La ganancia del dia en esta fase se calculara como:
  - ingresos del dia menos egresos del dia
- `Ventas del mes` debe representar el monto total vendido en el mes actual.
- La UI sigue en espanol y el codigo en ingles.

## Fuera de esta fase
- graficos
- comparativas entre periodos
- filtros avanzados
- anulacion de ventas desde dashboard
- acceso a detalle completo de movimientos
- reportes por rango de fechas
- exportacion Excel/PDF
- configuracion editable del umbral de stock bajo

## Cambios tecnicos esperados
- Crear una nueva pantalla y un `DashboardController` o notifier con `ChangeNotifier` + `Provider`.
- Agregar al arbol de `Provider` los repositorios o servicios necesarios para calcular:
  - ventas del dia
  - egresos del dia
  - ventas del mes
  - stock actual por producto
- Anadir consultas auxiliares en repositorios si hacen falta, sin redisenar las tablas:
  - suma de ventas por rango de fechas
  - suma de egresos por rango de fechas
  - listado de productos activos con su stock calculado
- Reutilizar el calculo de stock por eventos ya existente.
- Integrar la nueva tab al `MainScreen` y refrescar el dashboard al entrar en ella.

## Test cases y validacion
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze`
- `flutter test`
- `flutter run`
- Escenarios minimos:
  - la app muestra tabs para `Dashboard`, `Productos`, `Ventas` y `Egresos`
  - si no hay datos, el dashboard muestra ceros sin errores
  - una venta registrada incrementa ingresos del dia
  - un egreso registrado incrementa egresos del dia
  - la ganancia del dia cambia correctamente
  - las ventas del mes reflejan el total vendido en el mes actual
  - los productos con stock bajo aparecen en la seccion correspondiente
  - un ajuste o venta que cambie stock actualiza esa lista al refrescar

## Supuestos y defaults
- Fase 6 sera solo dashboard base, no reportes.
- El umbral de stock bajo sera fijo en `5` para evitar agregar configuracion temprana.
- La ganancia visible de esta fase sera operativa y simple: ingresos menos egresos, sin costo de producto ni margen real detallado.
- No se agregara navegacion secundaria desde el dashboard a otras pantallas en esta fase.
