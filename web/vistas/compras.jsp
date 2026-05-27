<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap,java.util.ArrayList"%>

<%
  ArrayList<HashMap<String,String>> ordenes     = (ArrayList<HashMap<String,String>>) request.getAttribute("listaOrdenes");
  ArrayList<HashMap<String,String>> detalles    = (ArrayList<HashMap<String,String>>) request.getAttribute("listaDetallesOrden");
  ArrayList<HashMap<String,String>> proveedores = (ArrayList<HashMap<String,String>>) request.getAttribute("listaProveedores");
  ArrayList<HashMap<String,String>> productos   = (ArrayList<HashMap<String,String>>) request.getAttribute("listaProductos");

  if (ordenes     == null) ordenes     = new ArrayList<>();
  if (detalles    == null) detalles    = new ArrayList<>();
  if (proveedores == null) proveedores = new ArrayList<>();
  if (productos   == null) productos   = new ArrayList<>();

  // esAdmin, esGerente ya declarados en dashboard.jsp (include estático)
  boolean puedeGestionar = esAdmin || esGerente;

  int pendientes = 0, parciales = 0, recibidas = 0, anuladas = 0;
  for (HashMap<String,String> o : ordenes) {
    String est = o.getOrDefault("estado", "pendiente");
    if      ("pendiente".equals(est)) pendientes++;
    else if ("parcial".equals(est))   parciales++;
    else if ("recibida".equals(est))  recibidas++;
    else if ("anulada".equals(est))   anuladas++;
  }
%>

<!-- HEADER -->
<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-file-invoice"></i> Órdenes de Compra
  </h2>
  <% if (puedeGestionar) { %>
  <button class="btn-add-user" onclick="abrirModalNuevaOrden()">
    <i class="fa-solid fa-plus"></i> Nueva Orden
  </button>
  <% } %>
</div>

<!-- ALERTA: pendientes -->
<% if (pendientes > 0) { %>
<div style="background:linear-gradient(90deg,#e3f2fd,#90caf9); border-left:4px solid #1976d2;
            border-radius:8px; padding:12px 18px; margin-bottom:10px;
            display:flex; align-items:center; gap:12px;">
  <i class="fa-solid fa-clock" style="color:#1565c0; font-size:18px;"></i>
  <span style="font-weight:600; color:#1565c0;"><%= pendientes %> orden(es) pendiente(s) de recibir</span>
</div>
<% } %>

<!-- ALERTA: recepción parcial -->
<% if (parciales > 0) { %>
<div style="background:linear-gradient(90deg,#fff8e1,#ffe082); border-left:4px solid #f9a825;
            border-radius:8px; padding:12px 18px; margin-bottom:18px;
            display:flex; align-items:center; gap:12px;">
  <i class="fa-solid fa-circle-half-stroke" style="color:#e65100; font-size:18px;"></i>
  <span style="font-weight:600; color:#e65100;"><%= parciales %> orden(es) con recepción parcial</span>
  <% if (puedeGestionar) { %>
  <span style="color:#bf360c; font-size:13px;">— el proveedor aún tiene productos pendientes de entregar</span>
  <% } %>
</div>
<% } %>

<!-- STATS -->
<div class="users-stats">
  <div class="stat-card total">
    <p><i class="fa-solid fa-clipboard-list"></i> Total Órdenes</p>
    <h3><%= ordenes.size() %></h3>
  </div>
  <div class="stat-card active">
    <p><i class="fa-solid fa-clock"></i> Pendientes / Parciales</p>
    <h3><%= pendientes + parciales %></h3>
  </div>
  <div class="stat-card inactive">
    <p><i class="fa-solid fa-circle-check"></i> Recibidas</p>
    <h3><%= recibidas %></h3>
  </div>
</div>

<!-- FILTROS -->
<div class="users-filters">
  <div class="search-box">
    <i class="fa fa-search"></i>
    <input type="text" id="searchOrden" placeholder="Buscar proveedor..." oninput="filtrarOrdenes()">
  </div>
  <select id="estadoOrdenFilter" onchange="filtrarOrdenes()">
    <option value="">🔄 Todos los estados</option>
    <option value="pendiente">⏳ Pendiente</option>
    <option value="parcial">🔶 Recepción Parcial</option>
    <option value="recibida">✅ Recibida</option>
    <option value="anulada">🚫 Anulada</option>
  </select>
</div>

<!-- GRID DE TARJETAS -->
<div class="users-grid" id="ordenesGrid">
  <% if (ordenes.isEmpty()) { %>
    <div style="grid-column:1/-1; text-align:center; padding:60px 20px; color:#999;">
      <i class="fa-solid fa-inbox" style="font-size:48px; margin-bottom:20px; display:block; opacity:0.5;"></i>
      <p>No hay órdenes de compra registradas</p>
    </div>
  <% } else {
       for (HashMap<String,String> o : ordenes) {
         String estado   = o.getOrDefault("estado", "pendiente");
         boolean esPend  = "pendiente".equals(estado);
         boolean esParcl = "parcial".equals(estado);
         boolean esAnul  = "anulada".equals(estado);
         boolean esRecib = "recibida".equals(estado);

         String estColor, estFont, estTexto, estIcono;
         if (esPend) {
           estColor="#fff3e0"; estFont="#e65100"; estTexto="Pendiente";  estIcono="hourglass-half";
         } else if (esParcl) {
           estColor="#fff8e1"; estFont="#f57f17"; estTexto="Parcial";    estIcono="circle-half-stroke";
         } else if (esRecib) {
           estColor="#E1F5EE"; estFont="#0F6E56"; estTexto="Recibida";   estIcono="circle-check";
         } else {
           estColor="#f5f5f5"; estFont="#999";    estTexto="Anulada";    estIcono="ban";
         }

         double total = 0;
         try { total = Double.parseDouble(o.getOrDefault("total","0")); } catch (Exception e) {}
         String provEsc = o.getOrDefault("proveedor","").replace("'", "\\'");
  %>
    <div class="user-card"
         data-proveedor="<%= o.getOrDefault("proveedor","").toLowerCase() %>"
         data-estado="<%= estado %>">

      <div class="user-top">
        <div style="flex:1; min-width:0;">
          <strong style="font-size:14px; display:block;">
            <i class="fa-solid fa-file-invoice"></i> Orden #<%= o.get("id") %>
          </strong>
          <small style="color:#888;"><%= o.getOrDefault("fecha","") %></small>
        </div>
        <span style="font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600;
                     background:<%= estColor %>; color:<%= estFont %>; white-space:nowrap;">
          <i class="fa-solid fa-<%= estIcono %>"></i> <%= estTexto %>
        </span>
      </div>

      <div class="user-info" style="margin-top:8px;">
        <p><i class="fa-solid fa-building"></i> <strong><%= o.getOrDefault("proveedor","") %></strong></p>
        <p style="margin:8px 0;">
          <i class="fa-solid fa-boxes-stacked"></i>
          Productos: <strong><%= o.getOrDefault("items","0") %></strong>
        </p>
        <p style="margin:0;">
          <i class="fa-solid fa-sack-dollar"></i>
          <strong style="color:#007bff; font-size:16px;">S/. <%= String.format("%.2f", total) %></strong>
        </p>
      </div>

      <div style="display:flex; gap:6px; margin-top:12px; justify-content:flex-end; flex-wrap:wrap;">
        <button onclick="verDetalleOrden('<%= o.get("id") %>','<%= provEsc %>','<%= o.getOrDefault("fecha","") %>','<%= String.format("%.2f", total) %>')"
                style="background:none; border:1px solid #007bff; color:#007bff; padding:6px 10px;
                       border-radius:6px; cursor:pointer; font-size:11px; font-weight:600;">
          <i class="fa-solid fa-eye"></i> Ver
        </button>
        <% if (puedeGestionar && (esPend || esParcl)) { %>
        <button onclick="abrirModalRecepcion('<%= o.get("id") %>','<%= provEsc %>')"
                style="background:linear-gradient(90deg,#00a152,#00d46a); color:white; border:none;
                       padding:6px 10px; border-radius:6px; cursor:pointer; font-size:11px; font-weight:600;">
          <i class="fa-solid fa-truck-ramp-box"></i> <%= esParcl ? "Completar" : "Recibir" %>
        </button>
        <% } %>
        <% if (puedeGestionar && !esAnul) { %>
        <button onclick="confirmarAnularOrden('<%= o.get("id") %>','<%= provEsc %>','<%= estTexto %>')"
                style="background:linear-gradient(90deg,#e53935,#c62828); color:white; border:none;
                       padding:6px 10px; border-radius:6px; cursor:pointer; font-size:11px; font-weight:600;">
          <i class="fa-solid fa-ban"></i> Anular
        </button>
        <% } %>
      </div>
    </div>
  <% }} %>
</div>

<!-- ====== MODALES ====== -->

<!-- MODAL: Nueva Orden -->
<div class="modal-overlay" id="modalNuevaOrden">
  <div class="modal" style="width:600px; max-height:85vh; overflow-y:auto;">
    <form method="POST" action="ServletGuardarOrden" onsubmit="prepararEnvioOrden(event)">
      <h2><i class="fa-solid fa-plus-circle" style="color:#007bff;"></i> Nueva Orden de Compra</h2>

      <label>Proveedor *</label>
      <select name="idProveedor" required>
        <option value="">-- Seleccione proveedor --</option>
        <% for (HashMap<String,String> prov : proveedores) { %>
          <option value="<%= prov.get("id") %>"><%= prov.get("nombre") %></option>
        <% } %>
      </select>

      <div style="margin:16px 0 8px;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
          <label style="margin:0; font-weight:600;">Productos *</label>
          <button type="button" onclick="agregarLinea()"
                  style="background:linear-gradient(90deg,#007bff,#5a67d8); color:white; border:none;
                         padding:5px 12px; border-radius:6px; cursor:pointer; font-size:12px; font-weight:600;">
            <i class="fa-solid fa-plus"></i> Agregar producto
          </button>
        </div>
        <div style="display:grid; grid-template-columns:2fr 80px 100px 36px; gap:8px;
                    padding:0 0 4px; font-size:12px; font-weight:600; color:#888;">
          <span>Producto</span><span>Cant.</span><span>P. compra</span><span></span>
        </div>
        <div id="lineasOrden"></div>
      </div>

      <div style="text-align:right; padding:10px 0; border-top:1px solid #eee; font-size:15px; font-weight:600; color:#333;">
        Total estimado: <span id="totalOrdenDisplay" style="color:#007bff;">S/. 0.00</span>
      </div>

      <input type="hidden" name="maxLinea" id="maxLinea" value="-1">

      <div class="modal-buttons">
        <button type="submit" class="btn-save"><i class="fa-solid fa-check"></i> Crear Orden</button>
        <button type="button" class="btn-cancel" onclick="cerrarModalNuevaOrden()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- MODAL: Detalle de Orden (ver) -->
<div class="modal-overlay" id="modalDetalleOrden">
  <div class="modal" style="width:580px;">
    <h2 id="detalleTitulo" style="font-size:16px;"></h2>
    <div style="display:flex; gap:20px; margin-bottom:14px; font-size:13px; color:#666;">
      <span><i class="fa-solid fa-calendar"></i> <strong id="detalleFecha"></strong></span>
      <span><i class="fa-solid fa-sack-dollar"></i> Total: <strong id="detalleTotal" style="color:#007bff;"></strong></span>
    </div>
    <table style="width:100%; border-collapse:collapse; font-size:13px;">
      <thead>
        <tr style="background:#f5f5f5;">
          <th style="text-align:left;   padding:8px 10px; border-bottom:1px solid #eee;">Producto</th>
          <th style="text-align:center; padding:8px 10px; border-bottom:1px solid #eee;">Pedido</th>
          <th style="text-align:center; padding:8px 10px; border-bottom:1px solid #eee;">Recibido</th>
          <th style="text-align:center; padding:8px 10px; border-bottom:1px solid #eee;">Pendiente</th>
          <th style="text-align:right;  padding:8px 10px; border-bottom:1px solid #eee;">P. Compra</th>
        </tr>
      </thead>
      <tbody id="detalleTabla"></tbody>
    </table>
    <div class="modal-buttons" style="margin-top:18px;">
      <button type="button" class="btn-cancel" style="width:100%;" onclick="cerrarDetalleOrden()">Cerrar</button>
    </div>
  </div>
</div>

<!-- MODAL: Registrar Recepción (parcial o total) -->
<div class="modal-overlay" id="modalRecepcion">
  <div class="modal" style="width:620px; max-height:85vh; overflow-y:auto;">
    <form id="formRecepcion" method="POST" action="ServletRecibirOrden">
      <input type="hidden" name="idOrden"    id="recepcionIdOrden">
      <input type="hidden" name="numLineas"  id="recepcionNumLineas">
      <div id="recepcionHiddenFields"></div>

      <h2><i class="fa-solid fa-truck-ramp-box" style="color:#00a152;"></i>
          Registrar Recepción — Orden #<span id="recepcionNumOrden"></span></h2>
      <p style="color:#666; font-size:13px; margin:-4px 0 14px;">
        <i class="fa-solid fa-building"></i> <strong id="recepcionProveedor"></strong>
      </p>

      <p style="font-size:12px; color:#888; margin-bottom:10px;">
        Ingresa la cantidad que efectivamente llegó. Puedes ingresar menos que lo pedido (recepción parcial).
      </p>

      <table style="width:100%; border-collapse:collapse; font-size:13px;">
        <thead>
          <tr style="background:#f5f5f5;">
            <th style="text-align:left;   padding:8px 10px; border-bottom:1px solid #eee;">Producto</th>
            <th style="text-align:center; padding:8px 10px; border-bottom:1px solid #eee;">Pedido</th>
            <th style="text-align:center; padding:8px 10px; border-bottom:1px solid #eee;">Ya recibido</th>
            <th style="text-align:center; padding:8px 10px; border-bottom:1px solid #eee; color:#00a152;">Recibir ahora</th>
            <th style="text-align:center; padding:8px 10px; border-bottom:1px solid #eee;">Pendiente</th>
          </tr>
        </thead>
        <tbody id="recepcionTablaBody"></tbody>
      </table>

      <div style="text-align:right; padding:10px 0; border-top:1px solid #eee; margin-top:10px;
                  font-size:14px; font-weight:600; color:#333;">
        Unidades a ingresar al inventario:
        <span id="recepcionTotalUnidades" style="color:#00a152; font-size:16px;">0</span>
      </div>

      <div class="modal-buttons">
        <button type="button" class="btn-save" onclick="enviarRecepcion()">
          <i class="fa-solid fa-check"></i> Confirmar recepción
        </button>
        <button type="button" class="btn-cancel" onclick="cerrarModalRecepcion()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- MODAL: Confirmar Anular Orden -->
<div class="modal-overlay" id="modalAnularOrden">
  <div class="modal" style="width:420px; text-align:center;">
    <form method="POST" action="ServletAnularOrden">
      <input type="hidden" name="idOrden" id="anularIdOrden">
      <div style="font-size:48px; margin-bottom:12px; color:#e53935;">
        <i class="fa-solid fa-ban"></i>
      </div>
      <h2 style="margin-bottom:8px;">Anular Orden de Compra</h2>
      <p style="color:#666; margin-bottom:6px;">
        ¿Confirmas la anulación de la orden de <strong id="anularProveedor"></strong>?
      </p>
      <p id="anularAviso" style="font-size:13px; margin-bottom:20px;"></p>
      <div class="modal-buttons">
        <button type="submit" class="btn-save"
                style="background:linear-gradient(90deg,#e53935,#c62828);">
          <i class="fa-solid fa-ban"></i> Confirmar anulación
        </button>
        <button type="button" class="btn-cancel" onclick="cerrarModalAnularOrden()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- Template oculto para select de producto (clonado en JS) -->
<select id="productoTemplate" style="display:none" aria-hidden="true">
  <option value="">-- Seleccione producto --</option>
  <% for (HashMap<String,String> p : productos) { %>
  <option value="<%= p.get("id") %>"><%= p.get("nombre") %></option>
  <% } %>
</select>

<!-- ====== DATOS Y SCRIPTS ====== -->
<script>
// Mapa de detalles por orden: { idOrden: [{idProducto, producto, cantidad, recibida, precio, subtotal}] }
var ordenDetalles = {};
<%
  for (HashMap<String,String> d : detalles) {
    String oid     = d.get("idOrden");
    String idProd  = d.getOrDefault("idProducto","0");
    String prod    = d.get("producto").replace("'", "\\'");
    String cant    = d.getOrDefault("cantidad","0");
    String recib   = d.getOrDefault("recibida","0");
    String prec    = d.getOrDefault("precioCompra","0");
    double sub     = 0;
    try { sub = Integer.parseInt(cant) * Double.parseDouble(prec); } catch(Exception ex) {}
%>
if (!ordenDetalles["<%= oid %>"]) ordenDetalles["<%= oid %>"] = [];
ordenDetalles["<%= oid %>"].push({
  idProducto: '<%= idProd %>',
  producto:   '<%= prod %>',
  cantidad:    <%= cant %>,
  recibida:    <%= recib %>,
  precio:      <%= prec %>,
  subtotal:    <%= String.format("%.2f", sub) %>
});
<% } %>

// ============================================================
// MODAL VER DETALLE
// ============================================================
function verDetalleOrden(id, proveedor, fecha, total) {
  document.getElementById("detalleTitulo").innerHTML =
    '<i class="fa-solid fa-file-invoice" style="color:#007bff;"></i> Orden #' + id + ' — ' + proveedor;
  document.getElementById("detalleFecha").textContent  = fecha;
  document.getElementById("detalleTotal").textContent  = "S/. " + total;

  var tbody = document.getElementById("detalleTabla");
  tbody.innerHTML = "";
  var items = ordenDetalles[id] || [];
  if (items.length === 0) {
    tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;padding:16px;color:#aaa;">Sin items</td></tr>';
  } else {
    items.forEach(function(item) {
      var pendiente = item.cantidad - item.recibida;
      var pColor    = pendiente > 0 ? "#e65100" : "#00a152";
      var tr = document.createElement("tr");
      tr.innerHTML =
        '<td style="padding:8px 10px; border-bottom:1px solid #f0f0f0;">' + item.producto + '</td>' +
        '<td style="padding:8px 10px; border-bottom:1px solid #f0f0f0; text-align:center;">' + item.cantidad + '</td>' +
        '<td style="padding:8px 10px; border-bottom:1px solid #f0f0f0; text-align:center; color:#00a152; font-weight:600;">' + item.recibida + '</td>' +
        '<td style="padding:8px 10px; border-bottom:1px solid #f0f0f0; text-align:center; color:' + pColor + '; font-weight:600;">' + pendiente + '</td>' +
        '<td style="padding:8px 10px; border-bottom:1px solid #f0f0f0; text-align:right;">S/. ' + parseFloat(item.precio).toFixed(2) + '</td>';
      tbody.appendChild(tr);
    });
  }
  document.getElementById("modalDetalleOrden").style.display = "flex";
}
function cerrarDetalleOrden() { document.getElementById("modalDetalleOrden").style.display = "none"; }
document.getElementById("modalDetalleOrden").addEventListener("click", function(e) {
  if (e.target === this) cerrarDetalleOrden();
});

// ============================================================
// MODAL NUEVA ORDEN
// ============================================================
var lineaMax = -1;

function abrirModalNuevaOrden() {
  document.getElementById("lineasOrden").innerHTML = "";
  document.getElementById("maxLinea").value = "-1";
  lineaMax = -1;
  agregarLinea();
  document.getElementById("modalNuevaOrden").style.display = "flex";
}
function cerrarModalNuevaOrden() { document.getElementById("modalNuevaOrden").style.display = "none"; }
document.getElementById("modalNuevaOrden").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalNuevaOrden();
});

function agregarLinea() {
  lineaMax++;
  document.getElementById("maxLinea").value = lineaMax;

  var src = document.getElementById("productoTemplate");
  var sel = src.cloneNode(true);
  sel.id = ""; sel.style.display = ""; sel.removeAttribute("aria-hidden");
  sel.name = "item_prod_" + lineaMax; sel.required = true;
  sel.onchange = calcularTotal;

  var cantInput = document.createElement("input");
  cantInput.type = "number"; cantInput.name = "item_cant_" + lineaMax;
  cantInput.placeholder = "Cant."; cantInput.min = "1"; cantInput.required = true;
  cantInput.oninput = calcularTotal; cantInput.style.cssText = "width:100%;";

  var precInput = document.createElement("input");
  precInput.type = "number"; precInput.name = "item_precio_" + lineaMax;
  precInput.placeholder = "0.00"; precInput.min = "0"; precInput.step = "0.01"; precInput.required = true;
  precInput.oninput = calcularTotal; precInput.style.cssText = "width:100%;";

  var btn = document.createElement("button");
  btn.type = "button"; btn.innerHTML = "✕";
  btn.style.cssText = "background:#e53935;color:white;border:none;border-radius:6px;cursor:pointer;font-size:13px;padding:8px;width:36px;";
  var idx = lineaMax;
  btn.onclick = function() { quitarLinea(idx); };

  var row = document.createElement("div");
  row.id = "linea_" + lineaMax;
  row.style.cssText = "display:grid;grid-template-columns:2fr 80px 100px 36px;gap:8px;margin-bottom:8px;align-items:center;";
  row.appendChild(sel); row.appendChild(cantInput); row.appendChild(precInput); row.appendChild(btn);
  document.getElementById("lineasOrden").appendChild(row);
}

function quitarLinea(idx) {
  var el = document.getElementById("linea_" + idx);
  if (el) { el.remove(); calcularTotal(); }
}

function calcularTotal() {
  var total = 0;
  for (var i = 0; i <= lineaMax; i++) {
    var cant = document.querySelector('[name="item_cant_'   + i + '"]');
    var prec = document.querySelector('[name="item_precio_' + i + '"]');
    if (cant && prec && cant.value && prec.value)
      total += parseInt(cant.value) * parseFloat(prec.value);
  }
  document.getElementById("totalOrdenDisplay").textContent = "S/. " + total.toFixed(2);
}

function prepararEnvioOrden(e) {
  if (document.querySelectorAll("#lineasOrden [id^='linea_']").length === 0) {
    e.preventDefault(); alert("Agrega al menos un producto.");
  }
}

// ============================================================
// MODAL RECEPCIÓN (parcial / total)
// ============================================================
function abrirModalRecepcion(id, proveedor) {
  document.getElementById("recepcionIdOrden").value      = id;
  document.getElementById("recepcionNumOrden").textContent = id;
  document.getElementById("recepcionProveedor").textContent = proveedor;
  document.getElementById("recepcionHiddenFields").innerHTML = "";

  var tbody = document.getElementById("recepcionTablaBody");
  tbody.innerHTML = "";
  var items = ordenDetalles[id] || [];
  var n = 0;

  items.forEach(function(item) {
    var pendiente = item.cantidad - item.recibida;
    if (pendiente <= 0) return; // ya completamente recibido

    var tr = document.createElement("tr");
    tr.setAttribute("data-prod", item.idProducto);
    tr.setAttribute("data-max",  pendiente);

    var inp = document.createElement("input");
    inp.type = "number"; inp.className = "inp-recibir";
    inp.min = "0"; inp.max = pendiente; inp.value = pendiente;
    inp.style.cssText = "width:70px; text-align:center; border:1px solid #ddd; border-radius:6px; padding:4px 6px;";
    inp.oninput = actualizarTotalRecepcion;

    var pendienteSpan = pendiente;
    tr.innerHTML =
      '<td style="padding:8px 10px; border-bottom:1px solid #f0f0f0;">' + item.producto + '</td>' +
      '<td style="padding:8px 10px; border-bottom:1px solid #f0f0f0; text-align:center;">' + item.cantidad + '</td>' +
      '<td style="padding:8px 10px; border-bottom:1px solid #f0f0f0; text-align:center; color:#00a152;">' + item.recibida + '</td>' +
      '<td style="padding:8px 10px; border-bottom:1px solid #f0f0f0; text-align:center;" id="td-inp-' + id + '-' + n + '"></td>' +
      '<td style="padding:8px 10px; border-bottom:1px solid #f0f0f0; text-align:center; color:#e65100;" class="col-pendiente">' + pendienteSpan + '</td>';

    tbody.appendChild(tr);
    tr.querySelector("#td-inp-" + id + "-" + n).appendChild(inp);
    n++;
  });

  document.getElementById("recepcionNumLineas").value = n;
  actualizarTotalRecepcion();
  document.getElementById("modalRecepcion").style.display = "flex";
}

function actualizarTotalRecepcion() {
  var total = 0;
  document.querySelectorAll(".inp-recibir").forEach(function(inp) {
    total += parseInt(inp.value) || 0;
  });
  document.getElementById("recepcionTotalUnidades").textContent = total;
}

function enviarRecepcion() {
  var rows = document.querySelectorAll("#recepcionTablaBody tr");
  var container = document.getElementById("recepcionHiddenFields");
  container.innerHTML = "";
  var n = 0; var hayCantidad = false;

  rows.forEach(function(row) {
    var idProd = row.getAttribute("data-prod");
    var inp    = row.querySelector(".inp-recibir");
    var cant   = parseInt(inp ? inp.value : 0) || 0;

    var hProd = document.createElement("input");
    hProd.type = "hidden"; hProd.name = "item_prod_"     + n; hProd.value = idProd;
    container.appendChild(hProd);

    var hCant = document.createElement("input");
    hCant.type = "hidden"; hCant.name = "item_recibido_" + n; hCant.value = cant;
    container.appendChild(hCant);

    if (cant > 0) hayCantidad = true;
    n++;
  });

  if (!hayCantidad) { alert("Ingresa al menos una cantidad mayor a 0."); return; }
  document.getElementById("recepcionNumLineas").value = n;
  document.getElementById("formRecepcion").submit();
}

function cerrarModalRecepcion() { document.getElementById("modalRecepcion").style.display = "none"; }
document.getElementById("modalRecepcion").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalRecepcion();
});

// ============================================================
// MODAL ANULAR ORDEN
// ============================================================
function confirmarAnularOrden(id, proveedor, estadoActual) {
  document.getElementById("anularIdOrden").value          = id;
  document.getElementById("anularProveedor").textContent  = proveedor;
  var aviso = document.getElementById("anularAviso");
  if (estadoActual === "Recibida") {
    aviso.style.color = "#c62828";
    aviso.textContent = "⚠️ Esta orden ya fue recibida completamente. Anularla descontará todos los productos del inventario.";
  } else if (estadoActual === "Parcial") {
    aviso.style.color = "#e65100";
    aviso.textContent = "⚠️ Esta orden tiene recepción parcial. Anularla descontará del inventario solo lo que ya fue recibido.";
  } else {
    aviso.style.color = "#888";
    aviso.textContent = "La orden está pendiente. Anularla no afectará el inventario.";
  }
  document.getElementById("modalAnularOrden").style.display = "flex";
}
function cerrarModalAnularOrden() { document.getElementById("modalAnularOrden").style.display = "none"; }
document.getElementById("modalAnularOrden").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalAnularOrden();
});

// ============================================================
// FILTROS
// ============================================================
function filtrarOrdenes() {
  var search = document.getElementById("searchOrden").value.toLowerCase();
  var estado = document.getElementById("estadoOrdenFilter").value;
  var cards  = document.querySelectorAll("#ordenesGrid .user-card");
  cards.forEach(function(card) {
    var matchSearch = card.getAttribute("data-proveedor").includes(search);
    var matchEstado = !estado || card.getAttribute("data-estado") === estado;
    card.style.display = (matchSearch && matchEstado) ? "" : "none";
  });
}
</script>
