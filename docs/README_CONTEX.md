# README_CONTEXT.md
## Contexto global del proyecto — ERP Panadería (App móvil)

---

## 1. Propósito del proyecto

Este proyecto es una **aplicación móvil ERP básica para una panadería pequeña**, cuyo objetivo es:

- Registrar **ventas (ingresos)**
- Registrar **egresos (gastos)**
- Controlar **inventario (stock)**
- Calcular **ganancias reales**
- Generar y descargar **reportes de ventas en Excel y PDF**
- Funcionar **100% offline**

La aplicación está pensada para:
- 1 dueño
- 1 persona que atiende
- Un solo dispositivo Android

No es un sistema empresarial grande ni multiusuario.

---

## 2. Alcance funcional (qué SÍ hace la app)

La aplicación permite:

- Registrar ventas con uno o varios productos
- Registrar egresos con categoría y monto
- Gestionar productos e inventario
- Descontar stock automáticamente al vender
- Ajustar stock manualmente
- Ver un dashboard con:
  - Ingresos del día
  - Egresos del día
  - Ganancia
  - Ventas del mes
  - Productos con stock bajo
- Generar reportes de ventas:
  - Por día
  - Por mes
  - Por año
  - Por rango de fechas personalizado
- Exportar reportes:
  - Excel (CSV o XLSX) → numérico y visual
  - PDF → descriptivo y presentable

---

## 3. Fuera de alcance (qué NO hace la app)

Este proyecto NO incluye:

- Backend
- Servidor
- API REST
- Nube
- Sincronización entre dispositivos
- Usuarios / roles / autenticación
- Clientes
- Proveedores
- Facturación electrónica
- Impuestos
- Acceso web

Todo lo anterior está explícitamente fuera de alcance.

---

## 4. Stack tecnológico (FIJO, no negociable)

- Framework: **Flutter**
- Plataforma objetivo: **Android (first)**
- Base de datos local: **SQLite**
- ORM: **Drift**
- Manejo de estado: **Provider**
- Funcionamiento: **Offline**
- Lenguaje del código: **Inglés**
- Idioma de la aplicación (UI): **Español**
- Editor principal: **Visual Studio Code**
- Build / Run: **Android Studio**

Este stack NO debe cambiarse.

---

## 5. Arquitectura general

- No existe backend
- Toda la lógica vive en la app
- La base de datos es local
- La app sigue una separación clara:
  - Data (DB, repositorios)
  - Domain (modelos, servicios)
  - UI (pantallas, widgets)

Las decisiones de arquitectura ya están definidas en los archivos de fases `.md`.

---

## 6. Base de datos (principios)

- Las ventas NO se borran
- Las ventas solo se pueden anular
- Los reportes NO se guardan, se calculan
- El stock se mueve por eventos
- Los precios históricos se conservan
- La ganancia se calcula, no se persiste

---

## 7. Uso de IA (reglas obligatorias)

Cuando se implemente una fase:

- El archivo `fase_X.md` es la **fuente única de verdad**
- La IA debe:
  - Implementar SOLO lo indicado en esa fase
  - NO avanzar a la siguiente fase
  - NO inventar funcionalidades
  - NO modificar decisiones de arquitectura
- Cada fase debe compilar antes de continuar

La IA NO toma decisiones de producto ni arquitectura.

---

## 8. Flujo de trabajo esperado

1. Se crea el archivo `fase_X.md`
2. Se usa ese archivo como contexto para implementar
3. Se completa la fase
4. Se prueba que compile
5. Se hace commit
6. Se pasa a la siguiente fase

---

## 9. Objetivo final

Entregar una aplicación:

- Simple
- Estable
- Usable en el día a día
- Sin dependencias externas
- Con datos confiables
- Con reportes útiles para el dueño

Este proyecto prioriza **claridad y utilidad real**, no complejidad técnica innecesaria.

---

## 10. Regla final

Si algo no está definido en una fase `.md`, **no se implementa**.