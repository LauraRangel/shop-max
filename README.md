# SHOP-MAX — Sistema de Gestión de Ventas Retail

Sistema de información interno para la cadena comercial **SHOP-MAX**. Permite gestionar ventas, inventario, clientes, proveedores, compras y usuarios desde un panel administrativo con control de acceso por roles.

---

## Equipo

| Alumno | Módulos |
|---|---|
| Laura Isabel Rangel Terán | Login, Dashboard, Usuarios |
| Cristopher Brian Puican Reque | Ventas, Inventario, Compras |
| Willy Bryam Correa Iman | Clientes, Proveedores, Reportes |
| Dania Alexia Palomino García | Documentación |

**Curso:** Desarrollo Web Integrado — Sección 31197  
**Docente:** Claudia Karina Lazaro Perez  
**Universidad:** Universidad Tecnológica del Perú

---

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Backend | Java 23 + Jakarta Servlet 6.0 |
| Frontend | JSP + HTML + CSS + JavaScript |
| Base de datos | MySQL (XAMPP) |
| Servidor | Apache Tomcat 11 |
| IDE | NetBeans |
| Conector BD | mysql-connector-j-9.6.0 |

---

## Arquitectura

Patrón **MVC-DAO**:

```
src/java/
├── Controller/   → Servlets (@WebServlet)
├── Entity/       → POJOs
├── Model/        → DAOs con PreparedStatement
└── Utils/        → Conexión BD + hash de contraseñas

web/
├── login.jsp         → Pantalla de acceso
├── dashboard.jsp     → Contenedor principal (navegación por ?mod=)
├── vistas/           → Un JSP por módulo
└── WEB-INF/lib/      → mysql-connector-j-9.6.0.jar
```

---

## Roles y accesos

| Módulo | Administrador | Gerente | Cajero | Vendedor |
|---|---|---|---|---|
| Dashboard | ✅ | ✅ | ✅ | ✅ |
| Ventas | ✅ | ✅ | ✅ | ❌ |
| Inventario | ✅ | ✅ | ✅ | ✅ |
| Clientes | ✅ | ✅ | ✅ | ✅ |
| Proveedores | ✅ | ✅ | ❌ | ❌ |
| Compras | ✅ | ✅ | ✅ | ❌ |
| Reportes | ✅ | ✅ | ❌ | ❌ |
| Usuarios | ✅ | ❌ | ❌ | ❌ |

---

## Base de datos

**Nombre:** `shopmax`  
**Usuario:** `root` / sin contraseña  
**14 tablas:** `rol`, `tienda`, `usuario`, `categoria`, `producto`, `cliente`, `inventario_tienda`, `movimiento_inventario`, `venta`, `detalle_venta`, `comprobante`, `proveedor`, `orden_compra`, `detalle_orden`

---

## Instalación y configuración

### Requisitos previos
- JDK 23
- NetBeans IDE
- XAMPP (MySQL activo)
- Apache Tomcat 11

### Pasos

**1. Clonar el repositorio**
```bash
git clone <url-repositorio>
```

**2. Importar la base de datos**

Abrir phpMyAdmin → Importar → seleccionar `database/shopmax_final.sql`

**3. Abrir en NetBeans**

File → Open Project → seleccionar carpeta `SHOP-MAX`

**5. Ejecutar**

Clean and Build → Run (Tomcat 11)

La app abre en: `http://localhost:8080/SHOP-MAX/login`

---

## Usuarios de prueba

| Email | Contraseña | Rol |
|---|---|---|
| bryamci@gmail.com | 12345 | Administrador |
| maria@gmail.com | 1234 | Administrador |
| lucianac@gmail.com | luciana | Administrador |
| pedrol@gmail.com | 1234 | Vendedor |
| julion@gmail.com | 1234 | Cajero |

---

## Seguridad

- Contraseñas almacenadas con **SHA-256**
- Validación de sesión en cada request al dashboard
- Logout invalida la `HttpSession`
- Navegación por `?mod=` sin JavaScript para rutas principales
