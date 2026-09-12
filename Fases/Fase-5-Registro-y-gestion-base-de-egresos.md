# Fase 5 - Registro y Gestion Base de Egresos

## Resumen
Redactar `Fases/Fase-5-Registro-y-gestion-base-de-egresos.md` como la fase enfocada en incorporar el modulo visible de egresos para complementar los ingresos ya registrados por ventas. El objetivo es que el usuario pueda registrar, editar y consultar gastos basicos desde la app, usando la tabla `Expenses` y el repositorio ya creados en Fase 2.

La fase debe integrarse a la navegacion actual como una nueva tab junto a `Productos` y `Ventas`. No debe incluir todavia dashboard, reportes, exportacion ni calculo visible de ganancias.

## Cambios clave
- Agregar una nueva tab en la navegacion principal:
  - `Egresos`
- Mantener funcionales y sin rediseno profundo las tabs existentes:
  - `Productos`
  - `Ventas`
- Crear un modulo visible de egresos con una pantalla completa que permita:
  - registrar egresos
  - editar egresos existentes
  - listar egresos recientes
  - filtrar por rango de fechas simple
- Usar `ExpenseRepository` existente.
- Mantener `Expenses.category` como texto simple en esta fase.
- Mostrar feedback claro cuando un egreso se registra o actualiza correctamente.

## Interfaces y comportamiento esperado
- La tab de egresos debe mostrar estado vacio si no hay registros.
- La pantalla de egresos debe mostrar como minimo por cada item:
  - categoria
  - monto
  - notas si existen
  - fecha
- Debe existir un formulario para crear y editar egresos con estos campos:
  - categoria
  - monto
  - notas opcional
  - fecha
- Validaciones minimas:
  - categoria no vacia
  - monto mayor a cero
  - fecha valida
- El listado debe poder refrescarse tras crear o editar.
- El filtro por fechas puede resolverse con:
  - fecha inicio
  - fecha fin
- Si no hay filtro aplicado, mostrar egresos recientes en orden descendente por fecha.
- UI en espanol, codigo en ingles.

## Fuera de esta fase
- eliminar egresos
- categorias predefinidas
- dashboard
- reportes
- exportacion
- calculo visible de ganancias
- union de ingresos y egresos en una sola vista
- estadisticas o graficos

## Cambios tecnicos esperados
- Agregar `ExpenseRepository` al arbol de `Provider` si todavia no esta inyectado.
- Crear un `ExpenseController` o notifier con `ChangeNotifier` + `Provider`.
- Crear una pantalla de egresos y sus dialogos o formularios asociados.
- Anadir una estructura minima de filtro en memoria para rango de fechas.
- Mantener el modulo desacoplado de ventas y productos, salvo la convivencia en navegacion.

## Plan de pruebas y validacion
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze`
- `flutter test`
- `flutter run`
- Escenarios minimos:
  - la app muestra tabs para `Productos`, `Ventas` y `Egresos`
  - si no hay egresos, se muestra estado vacio
  - se puede crear un egreso y aparece en el listado
  - se puede editar un egreso existente
  - el filtro por rango devuelve solo los egresos dentro del periodo
  - el formulario no permite guardar monto invalido
  - el formulario no permite guardar categoria vacia

## Supuestos y defaults
- Fase 5 agrega solo el modulo base de egresos, no su analisis.
- La navegacion seguira siendo simple por tabs.
- No se agregara borrado de egresos en esta fase para mantener el alcance contenido.
- La fecha del egreso podra editarse desde el formulario porque ya es parte util del registro basico.
