<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>

<%
  if (!esAdmin && !esGerente) { %>
  <div style="text-align:center;padding:60px;color:#aaa">
    <i class="fa-solid fa-lock" style="font-size:3rem;margin-bottom:12px;display:block"></i>
    <p>No tienes permiso para acceder a este módulo.</p>
  </div>
<% return; } %>

<%
  @SuppressWarnings("unchecked")
  HashMap<String,String> kpis = (HashMap<String,String>) request.getAttribute("kpis");
  @SuppressWarnings("unchecked")
  ArrayList<HashMap<String,String>> topProductos    = (ArrayList<HashMap<String,String>>) request.getAttribute("topProductos");
  @SuppressWarnings("unchecked")
  ArrayList<HashMap<String,String>> ventasRecientes = (ArrayList<HashMap<String,String>>) request.getAttribute("ventasRecientes");
  @SuppressWarnings("unchecked")
  ArrayList<HashMap<String,String>> stockCritico    = (ArrayList<HashMap<String,String>>) request.getAttribute("stockCritico");
  @SuppressWarnings("unchecked")
  HashMap<String,String> porPago  = (HashMap<String,String>) request.getAttribute("ventasPorPago");
  @SuppressWarnings("unchecked")
  ArrayList<HashMap<String,String>> porMes = (ArrayList<HashMap<String,String>>) request.getAttribute("ventasPorMes");

  if (kpis         == null) kpis         = new HashMap<>();
  if (topProductos == null) topProductos = new ArrayList<>();
  if (ventasRecientes == null) ventasRecientes = new ArrayList<>();
  if (stockCritico == null) stockCritico = new ArrayList<>();
  if (porPago      == null) porPago      = new HashMap<>();
  if (porMes       == null) porMes       = new ArrayList<>();

  String ventasPeriodo    = kpis.getOrDefault("ventasPeriodo",    "0");
  String ingresosPeriodo  = kpis.getOrDefault("ingresosPeriodo",  "0.00");
  int    critico          = Integer.parseInt(kpis.getOrDefault("stockCritico",      "0"));
  int    pendientes       = Integer.parseInt(kpis.getOrDefault("ordenesPendientes", "0"));

  String filtroDesde = (String) request.getAttribute("filtroDesde");
  String filtroHasta = (String) request.getAttribute("filtroHasta");
  if (filtroDesde == null) filtroDesde = "";
  if (filtroHasta == null) filtroHasta = "";

  String efeCant  = porPago.getOrDefault("efectivo_cantidad","0");
  String efeTot   = porPago.getOrDefault("efectivo_total",   "0.00");
  String tarCant  = porPago.getOrDefault("tarjeta_cantidad", "0");
  String tarTot   = porPago.getOrDefault("tarjeta_total",    "0.00");
%>

<!-- Header -->
<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-chart-pie"></i> Reportes y Estadísticas
  </h2>
  <button class="btn-add-user" onclick="exportarTodo()">
    <i class="fa-solid fa-file-arrow-down"></i> Exportar Todo
  </button>
</div>

<!-- Filtro de fechas -->
<form method="GET" action="dashboard" style="background:#1e1e2e;border-radius:12px;padding:16px 20px;margin-bottom:20px;display:flex;align-items:flex-end;gap:16px;flex-wrap:wrap">
  <input type="hidden" name="mod" value="reportes">
  <div style="display:flex;flex-direction:column;gap:5px">
    <label style="color:#aaa;font-size:12px">Desde</label>
    <input type="date" name="desde" value="<%= filtroDesde %>"
           style="background:#16213e;border:1px solid rgba(255,255,255,.15);border-radius:8px;
                  color:#fff;padding:8px 12px;font-size:13px;outline:none">
  </div>
  <div style="display:flex;flex-direction:column;gap:5px">
    <label style="color:#aaa;font-size:12px">Hasta</label>
    <input type="date" name="hasta" value="<%= filtroHasta %>"
           style="background:#16213e;border:1px solid rgba(255,255,255,.15);border-radius:8px;
                  color:#fff;padding:8px 12px;font-size:13px;outline:none">
  </div>
  <button type="submit" style="background:linear-gradient(90deg,#6c63ff,#a78bfa);border:none;color:#fff;
                                padding:9px 20px;border-radius:8px;cursor:pointer;font-size:13px;font-weight:600">
    <i class="fa-solid fa-filter"></i> Filtrar
  </button>
  <a href="dashboard?mod=reportes" style="color:#aaa;font-size:13px;padding:9px 16px;border:1px solid rgba(255,255,255,.15);
                                           border-radius:8px;text-decoration:none">
    <i class="fa-solid fa-rotate-left"></i> Limpiar
  </a>
  <span style="color:#6c63ff;font-size:12px;margin-left:auto;align-self:center">
    <i class="fa-solid fa-calendar-range"></i> Mostrando: <strong><%= filtroDesde %></strong> → <strong><%= filtroHasta %></strong>
  </span>
</form>

<!-- Alertas -->
<% if (critico > 0) { %>
<div style="background:rgba(239,68,68,.15);border:1px solid rgba(239,68,68,.4);
            border-radius:10px;padding:12px 18px;margin-bottom:16px;
            display:flex;align-items:center;gap:10px;color:#ef4444">
  <i class="fa-solid fa-triangle-exclamation"></i>
  <span><strong><%= critico %> producto<%= critico>1?"s":"" %></strong> con stock por debajo del mínimo. Revisa la sección de Stock Crítico.</span>
</div>
<% } %>
<% if (pendientes > 0) { %>
<div style="background:rgba(59,130,246,.15);border:1px solid rgba(59,130,246,.4);
            border-radius:10px;padding:12px 18px;margin-bottom:16px;
            display:flex;align-items:center;gap:10px;color:#3b82f6">
  <i class="fa-solid fa-clock"></i>
  <span><strong><%= pendientes %> orden<%= pendientes>1?"es":"" %> de compra</strong> pendiente<%= pendientes>1?"s":"" %> de recepción.</span>
</div>
<% } %>

<!-- KPI Cards -->
<div class="users-stats" style="grid-template-columns:repeat(4,1fr)">
  <div class="stat-card total">
    <p><i class="fa-solid fa-cart-shopping"></i> Ventas en Período</p>
    <h3><%= ventasPeriodo %></h3>
    <small style="opacity:.75;font-size:11px"><%= filtroDesde %> → <%= filtroHasta %></small>
  </div>
  <div class="stat-card income">
    <p><i class="fa-solid fa-sack-dollar"></i> Ingresos en Período</p>
    <h3>S/ <%= ingresosPeriodo %></h3>
    <small style="opacity:.75;font-size:11px">ventas completadas</small>
  </div>
  <div class="stat-card monthly">
    <p><i class="fa-solid fa-triangle-exclamation"></i> Stock Crítico</p>
    <h3><%= critico %></h3>
    <small style="opacity:.75;font-size:11px">productos bajo mínimo</small>
  </div>
  <div class="stat-card inactive">
    <p><i class="fa-solid fa-clock"></i> Órdenes Pendientes</p>
    <h3><%= pendientes %></h3>
    <small style="opacity:.75;font-size:11px">pendiente + parcial</small>
  </div>
</div>

<!-- Fila: Top productos + Forma de pago -->
<div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-top:20px">

  <!-- Top 5 productos -->
  <div style="background:#1e1e2e;border-radius:12px;padding:20px">
    <h3 style="color:#fff;margin:0 0 16px;font-size:15px">
      <i class="fa-solid fa-trophy" style="color:#f59e0b"></i> Top Productos Más Vendidos
    </h3>
    <% if (topProductos.isEmpty()) { %>
      <p style="color:#aaa;text-align:center;padding:20px">Sin datos de ventas aún</p>
    <% } else {
         int rank = 1;
         for (HashMap<String,String> p : topProductos) {
           String color = rank == 1 ? "#f59e0b" : rank == 2 ? "#9ca3af" : rank == 3 ? "#cd7f32" : "#6c63ff";
           String badgeRankStyle = "width:28px;height:28px;border-radius:50%;background:" + color + ";display:flex;align-items:center;justify-content:center;font-weight:700;font-size:13px;color:#fff;flex-shrink:0";
    %>
    <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid rgba(255,255,255,.07)">
      <span style="<%= badgeRankStyle %>"><%= rank %></span>
      <div style="flex:1;min-width:0">
        <div style="color:#fff;font-size:13px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">
          <%= p.get("nombre") %>
        </div>
        <div style="color:#aaa;font-size:11px"><%= p.get("cantidad") %> unidades vendidas</div>
      </div>
      <span style="color:#6c63ff;font-size:13px;font-weight:600;white-space:nowrap">
        S/ <%= p.get("ingresos") %>
      </span>
    </div>
    <% rank++; } } %>
  </div>

  <!-- Forma de pago + Ventas por mes -->
  <div style="display:flex;flex-direction:column;gap:20px">

    <!-- Forma de pago -->
    <div style="background:#1e1e2e;border-radius:12px;padding:20px">
      <h3 style="color:#fff;margin:0 0 16px;font-size:15px">
        <i class="fa-solid fa-credit-card" style="color:#6c63ff"></i> Ventas por Forma de Pago
      </h3>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
        <div style="background:#16213e;border-radius:10px;padding:14px;text-align:center">
          <i class="fa-solid fa-money-bill-wave" style="color:#22c55e;font-size:1.4rem"></i>
          <div style="color:#aaa;font-size:11px;margin-top:6px">Efectivo</div>
          <div style="color:#fff;font-size:18px;font-weight:700"><%= efeCant %></div>
          <div style="color:#22c55e;font-size:12px">S/ <%= efeTot %></div>
        </div>
        <div style="background:#16213e;border-radius:10px;padding:14px;text-align:center">
          <i class="fa-solid fa-credit-card" style="color:#3b82f6;font-size:1.4rem"></i>
          <div style="color:#aaa;font-size:11px;margin-top:6px">Tarjeta</div>
          <div style="color:#fff;font-size:18px;font-weight:700"><%= tarCant %></div>
          <div style="color:#3b82f6;font-size:12px">S/ <%= tarTot %></div>
        </div>
      </div>
    </div>

    <!-- Ventas por mes (últimos meses) -->
    <div style="background:#1e1e2e;border-radius:12px;padding:20px;flex:1">
      <h3 style="color:#fff;margin:0 0 14px;font-size:15px">
        <i class="fa-solid fa-calendar-check" style="color:#a78bfa"></i> Ventas por Mes
      </h3>
      <% if (porMes.isEmpty()) { %>
        <p style="color:#aaa;text-align:center;padding:16px">Sin datos</p>
      <% } else {
           for (HashMap<String,String> m : porMes) {
      %>
      <div style="display:flex;justify-content:space-between;align-items:center;
                  padding:7px 0;border-bottom:1px solid rgba(255,255,255,.06)">
        <span style="color:#ccc;font-size:13px"><%= m.get("mes") %></span>
        <span style="color:#aaa;font-size:12px"><%= m.get("cantidad") %> ventas</span>
        <span style="color:#a78bfa;font-weight:600;font-size:13px">S/ <%= m.get("total") %></span>
      </div>
      <% } } %>
    </div>

  </div>
</div>

<!-- Últimas ventas -->
<div style="background:#1e1e2e;border-radius:12px;padding:20px;margin-top:20px">
  <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
    <h3 style="color:#fff;margin:0;font-size:15px">
      <i class="fa-solid fa-clock-rotate-left" style="color:#06b6d4"></i> Últimas 10 Ventas
    </h3>
    <button onclick="exportarCSV('tablaVentas','ventas_recientes')" style="background:none;border:1px solid #06b6d4;color:#06b6d4;padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px">
      <i class="fa-solid fa-file-csv"></i> Exportar CSV
    </button>
  </div>
  <div style="overflow-x:auto">
    <table style="width:100%;border-collapse:collapse;font-size:13px">
      <thead>
        <tr style="border-bottom:1px solid rgba(255,255,255,.1)">
          <th style="padding:8px 10px;color:#aaa;text-align:left;font-weight:500">#</th>
          <th style="padding:8px 10px;color:#aaa;text-align:left;font-weight:500">Cliente</th>
          <th style="padding:8px 10px;color:#aaa;text-align:left;font-weight:500">Vendedor</th>
          <th style="padding:8px 10px;color:#aaa;text-align:left;font-weight:500">Fecha</th>
          <th style="padding:8px 10px;color:#aaa;text-align:right;font-weight:500">Total</th>
          <th style="padding:8px 10px;color:#aaa;text-align:center;font-weight:500">Pago</th>
          <th style="padding:8px 10px;color:#aaa;text-align:center;font-weight:500">Estado</th>
        </tr>
      </thead>
      <tbody id="tablaVentas">
        <% if (ventasRecientes.isEmpty()) { %>
        <tr><td colspan="7" style="color:#aaa;text-align:center;padding:24px">Sin ventas registradas</td></tr>
        <% } else {
             for (HashMap<String,String> v : ventasRecientes) {
               boolean anulada = "anulada".equals(v.get("estado"));
               String badgeColor  = anulada ? "#ef4444" : "#22c55e";
               String badgeBg     = anulada ? "rgba(239,68,68,.15)" : "rgba(34,197,94,.15)";
               String badgeLabel  = anulada ? "Anulada" : "Completada";
               String pagoIcon    = "tarjeta".equals(v.get("tipoPago")) ? "fa-credit-card" : "fa-money-bill-wave";
               String pagoColor   = "tarjeta".equals(v.get("tipoPago")) ? "#3b82f6" : "#22c55e";
               String pagoIconStyle  = "color:" + pagoColor;
               String badgeStyle     = "background:" + badgeBg + ";color:" + badgeColor + ";padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600";
        %>
        <tr style="border-bottom:1px solid rgba(255,255,255,.05)">
          <td style="padding:9px 10px;color:#6c63ff;font-weight:600">#<%= v.get("id") %></td>
          <td style="padding:9px 10px;color:#fff"><%= v.get("cliente") %></td>
          <td style="padding:9px 10px;color:#ccc"><%= v.get("vendedor") %></td>
          <td style="padding:9px 10px;color:#aaa;font-size:12px"><%= v.get("fecha") %></td>
          <td style="padding:9px 10px;color:#fff;text-align:right;font-weight:600">S/ <%= v.get("total") %></td>
          <td style="padding:9px 10px;text-align:center">
            <i class="fa-solid <%= pagoIcon %>" style="<%= pagoIconStyle %>"></i>
          </td>
          <td style="padding:9px 10px;text-align:center">
            <span style="<%= badgeStyle %>"><%= badgeLabel %></span>
          </td>
        </tr>
        <% } } %>
      </tbody>
    </table>
  </div>
</div>

<!-- Stock crítico -->
<% if (!stockCritico.isEmpty()) { %>
<div style="background:#1e1e2e;border-radius:12px;padding:20px;margin-top:20px">
  <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
    <h3 style="color:#ef4444;margin:0;font-size:15px">
      <i class="fa-solid fa-triangle-exclamation"></i> Stock Crítico —
      <span style="color:#aaa;font-weight:400"><%= stockCritico.size() %> producto<%= stockCritico.size()>1?"s":"" %> por debajo del mínimo</span>
    </h3>
    <button onclick="exportarCSV('tablaStock','stock_critico')" style="background:none;border:1px solid #ef4444;color:#ef4444;padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px">
      <i class="fa-solid fa-file-csv"></i> Exportar CSV
    </button>
  </div>
  <div style="overflow-x:auto">
    <table style="width:100%;border-collapse:collapse;font-size:13px">
      <thead>
        <tr style="border-bottom:1px solid rgba(255,255,255,.1)">
          <th style="padding:8px 10px;color:#aaa;text-align:left;font-weight:500">Código</th>
          <th style="padding:8px 10px;color:#aaa;text-align:left;font-weight:500">Producto</th>
          <th style="padding:8px 10px;color:#aaa;text-align:left;font-weight:500">Categoría</th>
          <th style="padding:8px 10px;color:#aaa;text-align:center;font-weight:500">Stock Actual</th>
          <th style="padding:8px 10px;color:#aaa;text-align:center;font-weight:500">Stock Mínimo</th>
          <th style="padding:8px 10px;color:#aaa;text-align:center;font-weight:500">Déficit</th>
        </tr>
      </thead>
      <tbody id="tablaStock">
        <% for (HashMap<String,String> s : stockCritico) {
             int stockAct = Integer.parseInt(s.get("stock"));
             int stockMin = Integer.parseInt(s.get("minimo"));
             int deficit  = stockMin - stockAct;
        %>
        <tr style="border-bottom:1px solid rgba(255,255,255,.05)">
          <td style="padding:9px 10px;color:#aaa;font-family:monospace"><%= s.get("codigo") %></td>
          <td style="padding:9px 10px;color:#fff"><%= s.get("nombre") %></td>
          <td style="padding:9px 10px;color:#aaa"><%= s.get("categoria") %></td>
          <td style="padding:9px 10px;text-align:center">
            <span style="background:rgba(239,68,68,.15);color:#ef4444;
                         padding:3px 10px;border-radius:20px;font-weight:700">
              <%= stockAct %>
            </span>
          </td>
          <td style="padding:9px 10px;text-align:center;color:#aaa"><%= stockMin %></td>
          <td style="padding:9px 10px;text-align:center">
            <span style="color:#f59e0b;font-weight:600">-<%= deficit %></span>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>
<% } %>

<script>
  function exportarCSV(tbodyId, nombreArchivo) {
    var tbody   = document.getElementById(tbodyId);
    var table   = tbody ? tbody.closest("table") : null;
    if (!table) return;

    var filas   = [];
    // encabezados
    var ths = table.querySelectorAll("thead th");
    var enc = [];
    ths.forEach(function(th) { enc.push('"' + th.innerText.trim().replace(/"/g,'""') + '"'); });
    filas.push(enc.join(","));

    // filas de datos
    var trs = tbody.querySelectorAll("tr");
    trs.forEach(function(tr) {
      var celdas = tr.querySelectorAll("td");
      if (celdas.length === 0) return;
      var fila = [];
      celdas.forEach(function(td) {
        fila.push('"' + td.innerText.trim().replace(/"/g,'""') + '"');
      });
      filas.push(fila.join(","));
    });

    var csv  = "﻿" + filas.join("\n"); // BOM para Excel
    var blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    var url  = URL.createObjectURL(blob);
    var a    = document.createElement("a");
    a.href     = url;
    a.download = nombreArchivo + "_" + new Date().toISOString().slice(0,10) + ".csv";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }

  function exportarTodo() {
    exportarCSV("tablaVentas", "ventas_recientes");
    setTimeout(function() { exportarCSV("tablaStock", "stock_critico"); }, 400);
  }
</script>
