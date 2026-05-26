<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%
  HashMap<String,String> resumen =
      (HashMap<String,String>) request.getAttribute("resumen");

  String ventasHoy     = resumen != null ? resumen.get("ventasHoy")     : "0.00";
  String transacciones = resumen != null ? resumen.get("transacciones") : "0";
  String productos     = resumen != null ? resumen.get("productos")     : "0";
  String clientes      = resumen != null ? resumen.get("clientes")      : "0";
%>

<h1>Bienvenido, <%= session.getAttribute("nombre") %></h1>

<div class="cards">
  <div class="card card1">
    <i class="fa-solid fa-dollar-sign"></i>
    <h3>Ventas de Hoy</h3>
    <h2>S/. <%= ventasHoy %></h2>
    <p><%= transacciones %> transacciones</p>
  </div>
  <div class="card card2">
    <i class="fa-solid fa-box"></i>
    <h3>Productos</h3>
    <h2><%= productos %></h2>
    <p>En inventario</p>
  </div>
  <div class="card card3">
    <i class="fa-solid fa-users"></i>
    <h3>Clientes</h3>
    <h2><%= clientes %></h2>
    <p>Registrados</p>
  </div>
</div>

<%
  String rolHome    = (String) session.getAttribute("rol");
  boolean isAdmin   = "Administrador".equals(rolHome);
  boolean isGerente = "Gerente de Tienda".equals(rolHome);
  boolean isCajero  = "Cajero".equals(rolHome);
%>
<div class="quick">
  <h2><i class="fa-solid fa-bolt" style="color:#007bff;margin-right:8px"></i>Accesos R&aacute;pidos</h2>
  <div class="quick-grid">

    <% if (isAdmin || isGerente || isCajero) { %>
    <a href="dashboard?mod=ventas" class="quick-card">
      <div class="quick-icon" style="background:linear-gradient(135deg,#007bff,#7b2ff7)">
        <i class="fa-solid fa-cart-shopping"></i>
      </div>
      <div class="quick-card-text">
        <strong>Ventas</strong>
        <span>Registrar y consultar ventas</span>
      </div>
    </a>
    <% } %>

    <a href="dashboard?mod=inventario" class="quick-card">
      <div class="quick-icon" style="background:linear-gradient(135deg,#00c6ff,#0072ff)">
        <i class="fa-solid fa-box"></i>
      </div>
      <div class="quick-card-text">
        <strong>Inventario</strong>
        <span>Consultar stock de productos</span>
      </div>
    </a>

    <a href="dashboard?mod=clientes" class="quick-card">
      <div class="quick-icon" style="background:linear-gradient(135deg,#00b09b,#96c93d)">
        <i class="fa-solid fa-users"></i>
      </div>
      <div class="quick-card-text">
        <strong>Clientes</strong>
        <span>Gestionar clientes registrados</span>
      </div>
    </a>

    <% if (isAdmin || isGerente) { %>
    <a href="dashboard?mod=proveedores" class="quick-card">
      <div class="quick-icon" style="background:linear-gradient(135deg,#f7971e,#ffd200)">
        <i class="fa-solid fa-truck"></i>
      </div>
      <div class="quick-card-text">
        <strong>Proveedores</strong>
        <span>Gestionar proveedores</span>
      </div>
    </a>
    <% } %>

    <% if (isAdmin || isGerente || isCajero) { %>
    <a href="dashboard?mod=compras" class="quick-card">
      <div class="quick-icon" style="background:linear-gradient(135deg,#e96c6c,#e24b4a)">
        <i class="fa-solid fa-file-invoice"></i>
      </div>
      <div class="quick-card-text">
        <strong>Compras</strong>
        <span>&#211;rdenes de compra a proveedores</span>
      </div>
    </a>
    <% } %>

    <% if (isAdmin || isGerente) { %>
    <a href="dashboard?mod=reportes" class="quick-card">
      <div class="quick-icon" style="background:linear-gradient(135deg,#a18cd1,#fbc2eb)">
        <i class="fa-solid fa-chart-pie"></i>
      </div>
      <div class="quick-card-text">
        <strong>Reportes</strong>
        <span>Ventas e inventario en tiempo real</span>
      </div>
    </a>
    <% } %>

    <% if (isAdmin) { %>
    <a href="dashboard?mod=usuarios" class="quick-card">
      <div class="quick-icon" style="background:linear-gradient(135deg,#373b44,#4286f4)">
        <i class="fa-solid fa-user-gear"></i>
      </div>
      <div class="quick-card-text">
        <strong>Usuarios</strong>
        <span>Gestionar cuentas del sistema</span>
      </div>
    </a>
    <% } %>

  </div>
</div>
