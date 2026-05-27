<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>SHOP-MAX | Sistema</title>
  <link rel="stylesheet" href="css/system/styles.css">
  <link rel="stylesheet" href="css/system/users.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<%
  String mod = request.getParameter("mod");
  if (mod == null) mod = "home";
  String rol = (String) session.getAttribute("rol");
  boolean esAdmin    = "Administrador".equals(rol);
  boolean esGerente  = "Gerente de Tienda".equals(rol);
  boolean esCajero   = "Cajero".equals(rol);
  boolean esVendedor = "Vendedor".equals(rol);
%>

<div class="dashboard">

  <!-- SIDEBAR -->
  <aside class="sidebar" id="sidebar">
    <div class="sidebar-top">
      <img src="images/logo/logo_blanco.png" alt="SHOP-MAX">
      <h2>Sistema SHOP-MAX</h2>
      <button class="hamburger sidebar-close" onclick="toggleSidebar()" title="Cerrar menú">
        <span></span><span></span><span></span>
      </button>
    </div>
    <div class="divider"></div>
    <div class="sidebar-menu">
      <a href="dashboard" class="menu-item <%= "home".equals(mod) ? "active" : "" %>">
        <i class="fa-solid fa-chart-line"></i> Dashboard
      </a>
      <% if (esAdmin || esGerente || esCajero) { %>
      <a href="dashboard?mod=ventas" class="menu-item <%= "ventas".equals(mod) ? "active" : "" %>">
        <i class="fa-solid fa-cart-shopping"></i> Ventas
      </a>
      <% } %>
      <a href="dashboard?mod=inventario" class="menu-item <%= "inventario".equals(mod) ? "active" : "" %>">
        <i class="fa-solid fa-box"></i> Inventario
      </a>
      <a href="dashboard?mod=clientes" class="menu-item <%= "clientes".equals(mod) ? "active" : "" %>">
        <i class="fa-solid fa-users"></i> Clientes
      </a>
      <% if (esAdmin || esGerente) { %>
      <a href="dashboard?mod=proveedores" class="menu-item <%= "proveedores".equals(mod) ? "active" : "" %>">
        <i class="fa-solid fa-truck"></i> Proveedores
      </a>
      <% } %>
      <% if (esAdmin || esGerente || esCajero) { %>
      <a href="dashboard?mod=compras" class="menu-item <%= "compras".equals(mod) ? "active" : "" %>">
        <i class="fa-solid fa-file-invoice"></i> Compras
      </a>
      <% } %>
      <% if (esAdmin || esGerente) { %>
      <a href="dashboard?mod=reportes" class="menu-item <%= "reportes".equals(mod) ? "active" : "" %>">
        <i class="fa-solid fa-chart-pie"></i> Reportes
      </a>
      <% } %>
      <% if (esAdmin) { %>
      <a href="dashboard?mod=usuarios" class="menu-item <%= "usuarios".equals(mod) ? "active" : "" %>">
        <i class="fa-solid fa-user-gear"></i> Usuarios
      </a>
      <% } %>
    </div>
    <div class="divider"></div>
    <div class="sidebar-bottom">
      <a href="logout" class="logout">
        <i class="fa-solid fa-right-from-bracket"></i> Cerrar Sesión
      </a>
    </div>
  </aside>

  <!-- MAIN -->
  <main class="main">

<%
  String[] modTitulos = {
    "home","Dashboard",
    "ventas","Ventas",
    "inventario","Inventario",
    "clientes","Clientes",
    "proveedores","Proveedores",
    "compras","Compras",
    "reportes","Reportes",
    "usuarios","Gestión de Usuarios",
    "perfil","Mi Perfil"
  };
  String tituloActual = "Dashboard";
  for (int i = 0; i < modTitulos.length - 1; i += 2) {
    if (modTitulos[i].equals(mod)) { tituloActual = modTitulos[i+1]; break; }
  }
%>
    <!-- TOPBAR -->
    <div class="topbar">
      <div style="display:flex;align-items:center;gap:14px">
        <button class="hamburger topbar-open" id="btnOpenSidebar"
                onclick="toggleSidebar()" title="Abrir menú"
                style="display:none">
          <span></span><span></span><span></span>
        </button>
        <span class="topbar-title"><%= tituloActual %></span>
      </div>
      <div style="display:flex;align-items:center;gap:30px">
        <div style="text-align:right;font-size:12px;color:#888">
          <div id="time" style="font-weight:600;color:#333"></div>
          <div id="date" style="font-size:11px"></div>
        </div>
        <div class="user">
          <div>
            <strong><%= session.getAttribute("nombre") %></strong>
            <p><%= session.getAttribute("rol") %></p>
          </div>
          <a href="dashboard?mod=perfil" title="Configuración"
             style="text-decoration:none;color:<%= "perfil".equals(mod) ? "#7b2ff7" : "#aaa" %>">
            <i class="fa-solid fa-gear" style="font-size:18px;margin:0 8px;"></i>
          </a>
          <div class="avatar">
            <%= session.getAttribute("nombre").toString().charAt(0) %>
          </div>
        </div>
      </div>
    </div>

    <!-- CONTENIDO — include según ?mod= -->
    <div class="content">
      <% if      ("home".equals(mod))        { %> <%@ include file="vistas/home.jsp"        %>
      <% } else if ("ventas".equals(mod))    { %> <%@ include file="vistas/ventas.jsp"      %>
      <% } else if ("inventario".equals(mod)){ %> <%@ include file="vistas/inventario.jsp"  %>
      <% } else if ("clientes".equals(mod))  { %> <%@ include file="vistas/clientes.jsp"    %>
      <% } else if ("proveedores".equals(mod)){ %> <%@ include file="vistas/proveedores.jsp" %>
      <% } else if ("compras".equals(mod))   { %> <%@ include file="vistas/compras.jsp"     %>
      <% } else if ("reportes".equals(mod))  { %> <%@ include file="vistas/reportes.jsp"    %>
      <% } else if ("usuarios".equals(mod))  { %> <%@ include file="vistas/usuarios.jsp"    %>
      <% } else if ("perfil".equals(mod))   { %> <%@ include file="vistas/perfil.jsp"      %>
      <% } %>
    </div>

  </main>
</div>

<div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

<script>
  function actualizarFechaHora() {
    const now = new Date();
    document.getElementById("time").textContent = now.toLocaleTimeString("es-PE");
    document.getElementById("date").textContent = now.toLocaleDateString("es-PE",
      { weekday:"long", year:"numeric", month:"long", day:"numeric" });
  }
  actualizarFechaHora();
  setInterval(actualizarFechaHora, 1000);

  function toggleSidebar() {
    const sidebar  = document.getElementById("sidebar");
    const main     = document.querySelector(".main");
    const overlay  = document.getElementById("sidebarOverlay");
    const btnOpen  = document.getElementById("btnOpenSidebar");
    const isOpen   = !sidebar.classList.contains("collapsed");

    sidebar.classList.toggle("collapsed", isOpen);
    main.classList.toggle("expanded", isOpen);
    overlay.style.display  = isOpen ? "none" : "block";
    btnOpen.style.display  = isOpen ? "flex" : "none";
  }
</script>
</body>
</html>
