# Mejora - Dashboard responsivo y centrado

## Resumen
Mejorar la seccion de metricas del dashboard para que los recuadros se adapten al ancho disponible de pantalla, se mantengan centrados horizontalmente y no queden desalineados o apilados cuando existe espacio suficiente.

La mejora es solo visual. No cambia calculos, repositorios, base de datos, exportacion ni logica del dashboard.

## Cambios clave
- Reemplazar el `Wrap` directo de metricas por una seccion responsiva basada en `LayoutBuilder`.
- Calcular columnas segun el ancho logico disponible:
  - 3 columnas cuando el ancho permita una matriz comoda `3x2`.
  - 2 columnas en anchos intermedios.
  - 1 columna solo en pantallas estrechas.
- Centrar el grupo completo de tarjetas respecto al ancho util del dashboard.
- Mantener separacion uniforme horizontal y vertical entre tarjetas.
- Ajustar cada tarjeta de metrica para:
  - recibir un ancho calculado por la seccion responsiva.
  - centrar el label y el valor dentro del recuadro.
  - usar una altura estable para que las filas se vean parejas.

## Comportamiento esperado
- En pantallas con ancho suficiente, las seis metricas se muestran como matriz centrada `3x2`.
- En pantallas medianas, las metricas se muestran como `2x3`, centradas.
- En pantallas estrechas, las metricas pueden mostrarse en una columna, pero centradas y con ancho razonable.
- El label y el monto de cada tarjeta quedan centrados dentro del recuadro.
- La seccion `Productos con stock bajo` se mantiene funcional y sin cambios de logica.

## Cambios tecnicos esperados
- Crear un widget interno para la grilla responsiva de metricas en `dashboard_screen.dart`.
- Mantener las seis metricas actuales y sus colores actuales.
- No modificar `DashboardController`.
- No modificar tablas Drift ni repositorios.

## Test cases y validacion
- `flutter analyze`
- `flutter test`
- `flutter run`
- Escenarios minimos:
  - dashboard mantiene las seis tarjetas actuales.
  - tarjetas de metricas aparecen centradas horizontalmente.
  - texto y monto dentro de cada tarjeta aparecen centrados.
  - en ancho amplio, las tarjetas se ven como matriz `3x2`.
  - en ancho intermedio, las tarjetas se ven como matriz `2x3`.
  - el dashboard no cambia sus valores de ingresos, egresos, ganancias ni stock bajo.

## Supuestos
- Flutter debe responder al ancho logico disponible, no a pixeles fisicos exactos del dispositivo.
- Esta mejora no introduce configuracion, nuevas acciones de negocio ni cambios en reportes.
