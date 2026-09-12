# AGENTS.md

## Proyecto
Flutter ERP móvil para panadería — offline-first con Drift/SQLite + Provider.

## Stack (inmutable)
- Flutter (Android) · Drift (SQLite) · Provider · Código: inglés · UI: español

## Comandos principales (los ejecuta el humano, no el agente)
- `dart run build_runner build --delete-conflicting-outputs` — regenerar Drift tras editar `app_database.dart`
- `flutter analyze` — lint y typecheck
- `flutter test` — tests

## Arquitectura
- Single app, no monorepo
- Capas: `data/` (DB, repos) · `ui/` (screens, controllers) · `lib/main.dart` → `App`
- DB: SQLite via Drift en `panaderia_erp.db` (documents directory)
- Principios DB: ventas no se borran (solo anulan) · reportes se calculan · stock por eventos

## Contexto Global
- En el archivo `docs/README_CONTEX.md` se muestra el contexto global del proyecto.

## Workflow de fases
1. Leer archivo `Fases/Fase-X-*.md` o `docs/Mejoras/*.md`, tambien leer `docs/opencode_agent_context_app.md` para que tengas contexto de lo que ya haz implementado.
2. Implementar SOLO lo que dice el documento — nada más
3. Tras implementar, agregar UNA línea a `docs/opencode_agent_context_app.md` describiendo lo hecho
4. Guardar el plan de fase en `Fases/` como `.md`
5. Verificar: `build_runner` → `flutter analyze` → `flutter test`

## Reglas importantes
- Siempre que se pida crear un plan para una posible mejora, que se cree en la carpeta de `docs\Mejoras` con el prefijo `posible_mejora-[nombre-de-la-mejora]`

## Drift
- `lib/data/database/app_database.g.dart` es GENERADO — no editar
- Tablas: `Products`, `Sales`, `SaleItems`, `Expenses`, `StockMovements`
- Tests DB: `AppDatabase.forTesting(NativeDatabase.memory())`
- Widget tests: llamar `initializeSpanishLocaleForTests()` de `test/helpers/test_locale.dart` antes de pump


