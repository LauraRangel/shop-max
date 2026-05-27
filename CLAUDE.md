# CLAUDE.md — SHOP-MAX Sistema de Gestión de Tienda

> Documento de contexto completo para continuar el desarrollo en cualquier sesión.
> Universidad: UTP — Curso: Desarrollo Web Integrado
> Equipo: Laura Rangel (`feature/dashboard`) · Bryam Correa (`bryamDev`)

---

## 1. STACK TECNOLÓGICO

| Capa | Tecnología |
|---|---|
| Backend | Java 23, Jakarta EE 10 (`jakarta.servlet.*`) |
| Servidor | Apache Tomcat 11 (Homebrew: `/opt/homebrew/Cellar/tomcat/11.0.20/libexec`) |
| Base de datos | MySQL 8 vía XAMPP · DB: `shopmax` · usuario: `root` · sin contraseña |
| Frontend | JSP + scriptlets (`<% %>`, `<%= %>`), HTML5, CSS3, Font Awesome 6.5 |
| IDE | **Apache NetBeans** — ÚNICA forma de compilar. NUNCA usar `ant` desde terminal |
| Driver JDBC | `com.mysql.cj.jdbc.Driver` (mysql-connector-j 9.6.0) |
| Conexión | `jdbc:mysql://localhost/shopmax?useSSL=false&serverTimezone=UTC` |

---

## 2. ESTRUCTURA DE ARCHIVOS

```
SHOP-MAX/
├── src/java/
│   ├── Controller/          # 31 Servlets (@WebServlet)
│   ├── Model/               # 11 DAOs (acceso a BD)
│   ├── Entity/              # 3 POJOs (Cliente, Proveedor, Usuario)
│   └── Utils/
│       └── MysqlDBConexion.java   # getConexion() + hashPassword(SHA-256)
├── web/
│   ├── dashboard.jsp        # Contenedor principal — include estático de vistas
│   ├── login.jsp
│   ├── recuperar.jsp
│   ├── vistas/              # Módulos incluidos por dashboard.jsp
│   │   ├── home.jsp
│   │   ├── ventas.jsp
│   │   ├── inventario.jsp
│   │   ├── clientes.jsp
│   │   ├── proveedores.jsp
│   │   ├── compras.jsp
│   │   ├── reportes.jsp
│   │   ├── usuarios.jsp
│   │   └── perfil.jsp
│   ├── css/system/
│   │   ├── styles.css       # Layout: sidebar, topbar, content, cards
│   │   └── users.css        # Módulos: stat-cards, modal-overlay, user-card, filtros
│   └── images/logo/logo_blanco.png
├── database/shopmax_final.sql   # 14 tablas + datos de prueba
├── nbproject/
│   ├── project.properties   # Trackeado — usa ${j2ee.server.home} (NO server.domain)
│   └── private/             # Ignorado en git — contiene rutas locales de Tomcat
└── .gitignore
```

---

## 3. ARQUITECTURA Y PATRONES

### Patrón MVC-DAO

```
Browser → Servlet (Controller) → Model (DAO) → MySQL
                ↓
         request.setAttribute(...)
                ↓
         dashboard.jsp (include estático) → vista.jsp
```

- **Controller** (`Servlet*.java`): recibe request, valida sesión/rol, llama al Model, hace `setAttribute` y `forward`/`redirect`.
- **Model** (`Model*.java`): solo SQL. Devuelve `ArrayList<HashMap<String,String>>` o `HashMap<String,String>`. **Nunca** recibe `HttpServletRequest`.
- **Entity** (`Entity/*.java`): POJOs con getters/setters usados en operaciones de INSERT/UPDATE.
- **Utils**: `MysqlDBConexion` — método estático `getConexion()` y `hashPassword(String)`.

### Include Estático — Regla CRÍTICA

`dashboard.jsp` usa `<%@ include file="vistas/X.jsp" %>`. Esto compila TODOS los JSPs incluidos en un solo método `_jspService()`.

**Consecuencia:** Las variables declaradas en `dashboard.jsp` están en scope en TODAS las vistas:
```java
// Declaradas en dashboard.jsp — disponibles en todos los includes:
boolean esAdmin    = "Administrador".equals(rol);
boolean esGerente  = "Gerente de Tienda".equals(rol);
boolean esCajero   = "Cajero".equals(rol);
boolean esVendedor = "Vendedor".equals(rol);
```
**NUNCA redeclararlas en las vistas incluidas** — causa error de compilación "variable already defined".

### Transacciones JDBC

Patrón estándar en todo Model que toca múltiples tablas:
```java
cn.setAutoCommit(false);
// ... operaciones ...
cn.commit();
// en catch:
cn.rollback();
// en finally:
cn.setAutoCommit(true); cn.close();
```

---

## 4. REGLAS JSP/JS — CRÍTICAS

### JSP EL vs Template Literals

El motor JSP procesa `${...}` dentro de `<script>`. Los template literals de JS (backticks) consumen `${variable}` y producen string vacío.

```js
// ❌ MAL — JSP consume ${item.nombre} → string vacío
var html = `<td>${item.nombre}</td>`;

// ✅ BIEN — concatenación clásica
var html = "<td>" + item.nombre + "</td>";
```

**Regla:** Usar siempre `var` + concatenación de strings en JS dentro de archivos `.jsp`. Nunca template literals.

### Expresiones dentro de atributos style=""

El linter CSS de VS Code marca error en `style="color:<%= var %>"` — es un **falso positivo**. No afecta compilación ni runtime. Para silenciarlo, construir el estilo en el scriptlet:
```java
String estiloSpan = "color:" + color + ";font-weight:bold";
```
```html
<span style="<%= estiloSpan %>">...</span>
```

### Errores "The import jakarta cannot be resolved" en VS Code

**Falso positivo** en archivos `.java` nuevos hasta que NetBeans reindexe el proyecto. Los servlets existentes con imports idénticos compilan sin problema. Ignorar en VS Code; compilar desde NetBeans.

---

## 5. SESIÓN — ATRIBUTOS

| Atributo | Tipo | Valor |
|---|---|---|
| `id_usuario` | `Integer` | ID del usuario autenticado |
| `nombre` | `String` | Nombre completo |
| `rol` | `String` | `"Administrador"` / `"Gerente de Tienda"` / `"Cajero"` / `"Vendedor"` |
| `id_tienda` | `Integer` | ID de tienda (default 1 si null) |

### Bloque estándar de validación en servlets

```java
HttpSession session = request.getSession(false);
if (session == null || session.getAttribute("id_usuario") == null) {
    response.sendRedirect("login");
    return;
}
String rol = (String) session.getAttribute("rol");
// Verificación de rol si aplica:
if (!"Administrador".equals(rol) && !"Gerente de Tienda".equals(rol)) {
    response.sendRedirect("dashboard?mod=X");
    return;
}
```

---

## 6. BASE DE DATOS — ESQUEMA COMPLETO

### Tablas y columnas

| # | Tabla | Columnas clave |
|---|---|---|
| 1 | `rol` | `ID_ROL`, `NOMBRE`, `PERMISOS` |
| 2 | `tienda` | `ID_TIENDA`, `NOMBRE`, `DIRECCION`, `TELEFONO(9)` |
| 3 | `usuario` | `ID_USUARIO`, `ID_ROL`, `ID_TIENDA`, `NOMBRE`, `EMAIL(unique)`, `PASSWORD_HASH`, `ACTIVO` |
| 4 | `categoria` | `ID_CATEGORIA`, `NOMBRE`, `DESCRIPCION` |
| 5 | `producto` | `ID_PRODUCTO`, `ID_CATEGORIA`, `CODIGO(unique)`, `NOMBRE`, `PRECIO decimal(10,2)`, `STOCK_MINIMO(default 5)` |
| 6 | `cliente` | `ID_CLIENTE`, `NOMBRE`, `EMAIL`, `TELEFONO`, `DOCUMENTO`, `FECHA_REGISTRO` |
| 7 | `inventario_tienda` | `ID_INVENTARIO`, `ID_PRODUCTO`, `ID_TIENDA`, `CANTIDAD`, `ULTIMA_ACTUALIZACION` |
| 8 | `movimiento_inventario` | `ID_MOVIMIENTO`, `ID_PRODUCTO`, `TIPO('entrada'/'salida')`, `CANTIDAD`, `FECHA`, `ORIGEN('venta'/'compra'/'ajuste'/'anulacion_compra')` |
| 9 | `venta` | `ID_VENTA`, `ID_CLIENTE(null)`, `ID_USUARIO`, `ID_TIENDA`, `FECHA`, `TOTAL decimal(10,2)`, `ESTADO('completada'/'anulada')`, `TIPO_PAGO('efectivo'/'tarjeta')` |
| 10 | `detalle_venta` | `ID_DETALLE`, `ID_VENTA`, `ID_PRODUCTO`, `CANTIDAD`, `PRECIO_UNITARIO decimal(10,2)`, `DESCUENTO(default 0)` |
| 11 | `comprobante` | `ID_COMPROBANTE`, `ID_VENTA`, `NUMERO(unique)`, `TIPO('boleta'/'factura')`, `EMISION` |
| 12 | `proveedor` | `ID_PROVEEDOR`, `RAZON_SOCIAL`, `RUC(11, unique)`, `CONTACTO`, `TELEFONO`, `EMAIL` |
| 13 | `orden_compra` | `ID_ORDEN`, `ID_PROVEEDOR`, `FECHA`, `ESTADO('pendiente'/'parcial'/'recibida'/'anulada')`, `TOTAL` |
| 14 | `detalle_orden` | `ID_DETALLE`, `ID_ORDEN`, `ID_PRODUCTO`, `CANTIDAD`, `PRECIO_COMPRA`, `CANTIDAD_RECIBIDA(default 0)` |

### Reglas de negocio en BD

- **IGV**: Los precios en `producto.PRECIO` son IGV-inclusive (18%). Base = PRECIO/1.18.
- **Comprobante**: `NUMERO` formato `B001-{ID_VENTA padded 5}` para boleta. Solo boleta implementado actualmente.
- **Stock**: `inventario_tienda` tiene stock por producto por tienda. La suma de todas las tiendas es el stock global.
- **CANTIDAD_RECIBIDA**: columna en `detalle_orden` agregada para tracking parcial. Migración:
  ```sql
  ALTER TABLE detalle_orden ADD COLUMN CANTIDAD_RECIBIDA INT NOT NULL DEFAULT 0;
  UPDATE detalle_orden do JOIN orden_compra oc ON do.ID_ORDEN = oc.ID_ORDEN
    SET do.CANTIDAD_RECIBIDA = do.CANTIDAD WHERE oc.ESTADO = 'recibida';
  ```

---

## 7. ROLES Y PERMISOS

### Strings exactos en BD y sesión

```
'Administrador' | 'Gerente de Tienda' | 'Cajero' | 'Vendedor'
```

### Matriz de acceso por módulo

| Módulo | Admin | Gerente | Cajero | Vendedor |
|---|---|---|---|---|
| Dashboard (home) | ✓ | ✓ | ✓ | ✓ |
| Ventas (ver + registrar) | ✓ | ✓ | ✓ | ✓ |
| Inventario (ver) | ✓ | ✓ | ✓ | ✓ |
| Inventario (CRUD + stock) | ✓ | ✓ | ✗ | ✗ |
| Clientes (ver) | ✓ | ✓ | ✓ | ✓ |
| Clientes (CRUD) | ✓ | ✓ | ✗ | ✗ |
| Proveedores (todo) | ✓ | ✓ | ✗ | ✗ |
| Compras (todo) | ✓ | ✓ | ✓ | ✗ |
| Reportes | ✓ | ✓ | ✗ | ✗ |
| Usuarios | ✓ | ✗ | ✗ | ✗ |

### Variables de control en vistas JSP

```java
boolean puedeGestionar = esAdmin || esGerente;  // CRUD en inventario/clientes/proveedores
```

---

## 8. FLUJO DE DATOS POR MÓDULO — ServletDashboard

`ServletDashboard.java` carga datos según `?mod=`:

```java
case "ventas":      listaVentas, listaDetalles, listaComprobantes, listaProductos, listaClientes
case "inventario":  listaProductos, listaCategorias
case "compras":     listaOrdenes, listaDetallesOrden, listaProveedores, listaProductos
case "clientes":    listaClientes (también en scope global)
case "proveedores": listaProveedores (también en scope global)
case "reportes":    kpis, topProductos, ventasRecientes, stockCritico, ventasPorPago, ventasPorMes,
                    filtroDesde, filtroHasta  ← filtro de fechas GET params
```

**Atributos globales** (cargados siempre, cualquier módulo):
`proveedores`, `clientes`, `roles`, `tiendas`, `usuarios`, `resumen`

---

## 9. INVENTARIO — FLUJO COMPLETO

```
Orden de compra RECIBIDA   → UPDATE inventario_tienda +cantidad  + INSERT movimiento(entrada/compra)
Orden PARCIAL completada   → igual, solo lo indicado en item_recibido_N
Orden ANULADA (recibida)   → UPDATE inventario_tienda -CANTIDAD_RECIBIDA + INSERT movimiento(salida/anulacion_compra)
Venta COMPLETADA           → UPDATE inventario_tienda -cantidad  + INSERT movimiento(salida/venta)
Venta ANULADA              → UPDATE inventario_tienda +cantidad  + INSERT movimiento(entrada/anulacion)
Entrada manual (ajuste)    → INSERT ON DUPLICATE KEY UPDATE inventario_tienda + INSERT movimiento(entrada/compra)
```

---

## 10. PATRONES VISUALES — SISTEMA DE DISEÑO

### Colores base

| Token | Valor | Uso |
|---|---|---|
| Sidebar bg | `rgb(14,31,54)` | Fondo sidebar |
| Menu hover | `#1f3a5f` | Hover item menú |
| Divider | `#2c3e50` | Líneas separadoras |
| Content bg | `rgb(229,232,255)` | Fondo área de contenido |
| Topbar bg | `#fff` | Barra superior |
| Primario | `#007bff` | Azul principal |
| Gradiente principal | `linear-gradient(90deg,#007bff,#7b2ff7)` | Botones, activo, avatar |
| Gradiente income | `linear-gradient(90deg,#059669,#06b6d4)` | Stat card verde |
| Gradiente monthly | `linear-gradient(90deg,#7c3aed,#a78bfa)` | Stat card violeta |
| Gradiente active | `linear-gradient(90deg,#28a745,#00c6ff)` | Stat card verde-cian |
| Gradiente inactive | `linear-gradient(90deg,#ff4d4d,#ff7b00)` | Stat card rojo-naranja |

### Tarjetas oscuras en módulos (compras, reportes, inventario)

Fondo `#1e1e2e`, interior `#16213e`, texto `#fff`/`#ccc`/`#aaa`. Patrón usado en módulos con cards de gestión.

### Componentes CSS clave

**`.modal-overlay`** — modal sin Bootstrap:
```css
display: none;  /* abierto: flex */
position: fixed; inset: 0;
background: rgba(0,0,0,0.6);
justify-content: center; align-items: center;
z-index: 99999;
```
Abierto/cerrado con JS: `element.style.display = "flex"` / `"none"`.
Click fuera cierra: `addEventListener("click", e => { if(e.target===this) cerrar(); })`.

**`.modal`**: `width:420px; background:#fff; border-radius:15px`

**`.stat-card`**: `padding:20px; border-radius:15px; color:#fff` + clase de color (`total`/`active`/`inactive`/`income`/`monthly`)

**`.users-grid`**: `display:grid; grid-template-columns:repeat(3,1fr); gap:20px`

**`.user-card`**: `background:#fff; padding:20px; border-radius:15px; box-shadow:0 10px 20px rgba(0,0,0,0.05)`

**`.gradient-text`**: `background:linear-gradient(90deg,#007bff,#7b2ff7); -webkit-background-clip:text; -webkit-text-fill-color:transparent`

**`.btn-add-user`**: `background:linear-gradient(90deg,#007bff,#7b2ff7); color:#fff; border-radius:30px; padding:10px 18px`

**Font Awesome 6.5** cargado vía CDN en `dashboard.jsp`.

### Fuente

`"Segoe UI", sans-serif` — definida en `*` del reset CSS.

---

## 11. PATRÓN DE MÓDULO — ESTRUCTURA ESTÁNDAR JSP

Cada vista en `web/vistas/` sigue este esquema:

```jsp
<%-- 1. Imports y cast de atributos --%>
<%@page import="java.util.HashMap,java.util.ArrayList"%>
<%
  ArrayList<HashMap<String,String>> lista =
      (ArrayList<HashMap<String,String>>) request.getAttribute("nombreAtributo");
  boolean puedeGestionar = esAdmin || esGerente;  // usa vars del scope global
%>

<%-- 2. Bloqueo por rol si aplica --%>
<% if (!puedeGestionar) { %>
  <div>No tienes permiso...</div>
<% return; } %>

<%-- 3. Header con título + botón acción --%>
<div class="users-header">
  <h2 class="gradient-text"><i class="fa-solid fa-icon"></i> Título</h2>
  <% if (puedeGestionar) { %>
  <button class="btn-add-user" onclick="abrirModal()">+ Agregar</button>
  <% } %>
</div>

<%-- 4. Stat cards --%>
<div class="users-stats">
  <div class="stat-card total"><p>Label</p><h3>valor</h3></div>
</div>

<%-- 5. Filtros --%>
<div class="users-filters">
  <div class="search-box"><input type="text" oninput="filtrar()"></div>
</div>

<%-- 6. Grid de cards --%>
<div class="users-grid" id="grid">...</div>
<div id="sinResultados" style="display:none">No se encontraron resultados</div>

<%-- 7. Modales (modal-overlay) --%>
<div class="modal-overlay" id="miModal">
  <div class="modal">
    <form method="POST" action="Servlet">
      <div class="modal-buttons">
        <button class="btn-save">Guardar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModal()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<%-- 8. Script — SIN template literals, SOLO var + concatenación --%>
<script>
  function abrirModal() { document.getElementById("miModal").style.display = "flex"; }
  function cerrarModal() { document.getElementById("miModal").style.display = "none"; }
</script>
```

---

## 12. PROCESOS BPMN — RESUMEN

### Ventas (POS)
1. Cajero/Vendedor/Admin/Gerente abre módulo Ventas
2. Busca cliente (opcional) + agrega productos al carrito
3. Selecciona tipo pago (efectivo/tarjeta)
4. `ServletGuardarVenta`: INSERT venta → INSERT detalle_venta → UPDATE inventario_tienda (-stock) → INSERT movimiento → INSERT comprobante (boleta B001-XXXXX)
5. Se genera ticket para impresión (print via JS)
6. Anulación: `ServletAnularVenta` → UPDATE venta ESTADO='anulada' + UPDATE inventario_tienda (+stock) + INSERT movimiento(entrada/anulacion)

### Compras (Órdenes)
1. Admin/Gerente crea orden → `ServletGuardarOrden`: INSERT orden_compra + INSERT detalle_orden
2. Estado inicial: `pendiente`
3. Recepción parcial: `ServletRecibirOrden` → UPDATE detalle_orden CANTIDAD_RECIBIDA += X → UPDATE/INSERT inventario_tienda → estado = `parcial`
4. Recepción total: mismo servlet → cuando COUNT(pendientes)=0 → estado = `recibida`
5. Anulación: `ServletAnularOrden` → estado = `anulada` → si era recibida/parcial: revertir CANTIDAD_RECIBIDA del inventario

### Inventario
- Entrada manual: `ServletEntradaStock` → INSERT ON DUPLICATE KEY UPDATE inventario_tienda + INSERT movimiento(entrada/compra)
- Editar producto: `ServletEditarProducto` → UPDATE producto
- Eliminar: `ServletEliminarProducto` (solo Admin)
- Stock mínimo: alerta visual cuando `CANTIDAD < STOCK_MINIMO`

### Clientes / Proveedores
- CRUD estándar via modals
- Clientes: todos ven, Admin/Gerente gestionan. DNI=8 dígitos, Teléfono=9 dígitos.
- Proveedores: solo Admin/Gerente ven y gestionan. RUC=11 dígitos.

### Reportes
- Solo Admin/Gerente
- Filtro de fechas GET params `desde`/`hasta` (default: primer día del mes → hoy)
- KPIs: ventas período, ingresos período, stock crítico, órdenes pendientes
- Export CSV desde tablas del DOM via JS Blob

### Usuarios
- Solo Admin
- CRUD completo. Contraseñas con SHA-256.

---

## 13. SERVLETS — MAPA COMPLETO

| Servlet | URL | Método | Roles | Descripción |
|---|---|---|---|---|
| `ServletLogin` | `/login` | GET+POST | — | Autenticación |
| `ServletLogout` | `/logout` | GET | — | Destruye sesión |
| `ServletDashboard` | `/dashboard` | GET | todos | Carga datos según `?mod=` |
| `ServletGuardarVenta` | `/ServletGuardarVenta` | POST | con sesión | INSERT venta completa |
| `ServletAnularVenta` | `/ServletAnularVenta` | POST | Admin/Gerente | Anula venta + revierte stock |
| `ServletGuardarOrden` | `/ServletGuardarOrden` | POST | Admin/Gerente | Crea orden de compra |
| `ServletRecibirOrden` | `/ServletRecibirOrden` | POST | Admin/Gerente | Recepción parcial/total |
| `ServletAnularOrden` | `/ServletAnularOrden` | POST | Admin/Gerente | Anula orden |
| `ServletEntradaStock` | `/ServletEntradaStock` | POST | Admin/Gerente | Entrada manual inventario |
| `ServletEditarProducto` | `/ServletEditarProducto` | POST | Admin/Gerente | UPDATE producto |
| `ServletEliminarProducto` | `/ServletEliminarProducto` | POST | Admin | DELETE producto |
| `ServletMantenimientoCliente` | `/ServletMantenimientoCliente` | POST | — ⚠️ sin sesión | INSERT cliente |
| `ServletEditarCliente` | `/EditarCliente` | POST | — ⚠️ sin sesión | UPDATE cliente |
| `ServletEliminarCliente` | `/EliminarCliente` | POST | — ⚠️ sin sesión | DELETE cliente |
| `ServletMantenimientoProveedor` | `/ServletMantenimientoProveedor` | POST | — ⚠️ sin sesión | INSERT proveedor |
| `ServletEditarProveedor` | `/EditarProveedor` | POST | — ⚠️ sin sesión | UPDATE proveedor |
| `ServletEliminarProveedor` | `/EliminarProveedor` | POST | — ⚠️ sin sesión | DELETE proveedor |
| `ServletMantenimientoUsuario` | `/ServletMantenimientoUsuario` | POST | — ⚠️ sin sesión | INSERT usuario |
| `ServletEditarUsuario` | `/ServletEditarUsuario` | POST | — ⚠️ sin sesión | UPDATE usuario |
| `ServletEliminarUsuario` | `/ServletEliminarUsuario` | POST | — ⚠️ sin sesión | DELETE usuario |
| `ServletGuardarProducto` | `/ServletGuardarProducto` | POST | — ⚠️ sin sesión | INSERT producto |
| `ServletCambiarPassword` | `/ServletCambiarPassword` | POST | — ⚠️ sin sesión | UPDATE password |

> ⚠️ Los marcados sin sesión son deuda técnica pendiente de corregir.

---

## 14. ESTADO DE IMPLEMENTACIÓN

| Módulo | Estado | Notas |
|---|---|---|
| Login / Logout | ✅ Completo | SHA-256, sesión |
| Dashboard home | ✅ Completo | KPIs via ModelHome |
| Ventas (POS) | ✅ Completo | IGV, boleta, anulación, stock |
| Inventario | ✅ Completo | CRUD, alertas, entrada stock, categorías |
| Clientes | ✅ Completo | CRUD, roles, validación DNI/tel |
| Proveedores | ✅ Completo | CRUD, roles, validación RUC/tel |
| Compras | ✅ Completo | Órdenes, recepción parcial/total, anulación |
| Reportes | ✅ Completo | KPIs, filtro fechas, top productos, export CSV |
| Usuarios | ✅ Completo | CRUD, roles |
| Perfil | ✅ Básico | Ver datos, cambiar password |

### Pendiente / Mejoras identificadas

| Prioridad | Item |
|---|---|
| 🔴 Crítico | Agregar validación de sesión en 14 servlets (ver tabla sección 13) |
| 🟠 Importante | Tipo de comprobante: factura con RUC del cliente (actualmente solo boleta) |
| 🟡 Mejora | Escape HTML en outputs JSP (XSS) |
| 🟡 Mejora | Validación server-side en servlets (null checks antes de parseInt) |
| 🟡 Mejora | Paginación en listados grandes |

---

## 15. RAMAS GIT

| Rama | Responsable | Contenido |
|---|---|---|
| `main` | — | Rama principal / producción |
| `feature/dashboard` | Laura Rangel | Dashboard, reportes, inventario, compras, roles |
| `bryamDev` | Bryam Correa | Clientes, proveedores, Entity POJOs |

### Notas de integración

- `nbproject/project.properties` está trackeado. Debe usar `${j2ee.server.home}` (NO `${j2ee.server.domain}`). El valor real se resuelve desde `nbproject/private/private.properties` (ignorado en git).
- Si después de un merge el proyecto no compila con "package jakarta.servlet does not exist", verificar que `j2ee.platform.classpath` use `${j2ee.server.home}`.

---

## 16. COMPILACIÓN Y DESPLIEGUE

1. **Siempre compilar desde NetBeans**: Run → Clean and Build Project (Shift+F11)
2. XAMPP debe estar corriendo con MySQL activo antes de iniciar Tomcat
3. Tomcat se inicia desde NetBeans automáticamente al hacer Run
4. URL local: `http://localhost:8080/SHOP-MAX/login`
5. Credenciales de prueba (SHA-256 en BD):
   - `bryamci@gmail.com` / `12345` → Administrador
   - `maria@gmail.com` / `1234` → Administrador
   - `pedrol@gmail.com` / `1234` → Vendedor
   - `julion@gmail.com` / `1234` → Cajero
