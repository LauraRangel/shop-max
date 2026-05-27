<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap,java.util.ArrayList"%>
<%@page import="java.time.LocalDate"%>

<%
  ArrayList<HashMap<String,String>> ventas =
      (ArrayList<HashMap<String,String>>) request.getAttribute("listaVentas");
  ArrayList<HashMap<String,String>> productos =
      (ArrayList<HashMap<String,String>>) request.getAttribute("listaProductos");
  ArrayList<HashMap<String,String>> clientes =
      (ArrayList<HashMap<String,String>>) request.getAttribute("listaClientes");
  ArrayList<HashMap<String,String>> detalles =
      (ArrayList<HashMap<String,String>>) request.getAttribute("listaDetalles");
  ArrayList<HashMap<String,String>> comprobantes =
      (ArrayList<HashMap<String,String>>) request.getAttribute("listaComprobantes");

  if (ventas       == null) ventas       = new ArrayList<>();
  if (productos    == null) productos    = new ArrayList<>();
  if (clientes     == null) clientes     = new ArrayList<>();
  if (detalles     == null) detalles     = new ArrayList<>();
  if (comprobantes == null) comprobantes = new ArrayList<>();

  String hoy = LocalDate.now().toString(); // "YYYY-MM-DD"

  double totalMonto = 0;
  int completadas = 0;
  int anuladas = 0;
  for (HashMap<String,String> v : ventas) {
    String fecha = v.getOrDefault("fecha", "");
    boolean esHoy = fecha.startsWith(hoy);
    if (!esHoy) continue;

    if ("completada".equals(v.get("estado"))) {
      completadas++;
      try { totalMonto += Double.parseDouble(v.get("total")); } catch(Exception e){}
    } else if ("anulada".equals(v.get("estado"))) {
      anuladas++;
    }
  }

  // esAdmin, esGerente, esCajero ya declarados en dashboard.jsp (include estático)
  boolean puedeVender = esAdmin || esGerente || esCajero;
  boolean puedeAnular = esAdmin || esGerente;
%>

<!-- ── HEADER ────────────────────────────────────────────── -->
<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-cart-shopping"></i> Punto de Venta
  </h2>
  <% if (puedeVender) { %>
  <button class="btn-add-user" onclick="abrirPOS()">
    <i class="fa-solid fa-plus"></i> Nueva Venta
  </button>
  <% } %>
</div>

<!-- ── STATS ─────────────────────────────────────────────── -->
<div class="users-stats">
  <div class="stat-card active">
    <p><i class="fa-solid fa-money-bill-wave"></i> Monto Hoy</p>
    <h3>S/. <%= String.format("%.2f", totalMonto) %></h3>
  </div>
  <div class="stat-card inactive">
    <p><i class="fa-solid fa-check-circle"></i> Completadas Hoy</p>
    <h3><%= completadas %></h3>
  </div>
  <div class="stat-card" style="background:linear-gradient(135deg,#e74c3c,#c0392b);">
    <p style="color:rgba(255,255,255,.85);"><i class="fa-solid fa-ban"></i> Anuladas Hoy</p>
    <h3 style="color:#fff;"><%= anuladas %></h3>
  </div>
</div>

<!-- ── FILTROS ────────────────────────────────────────────── -->
<div class="users-filters">
  <div class="search-box">
    <i class="fa fa-search"></i>
    <input type="text" id="searchVenta" placeholder="Buscar por cliente..." oninput="filtrarVentas()">
  </div>
  <select id="estadoFilter" onchange="filtrarVentas()">
    <option value="">🔄 Todos los estados</option>
    <option value="completada">✅ Completada</option>
    <option value="anulada">❌ Anulada</option>
  </select>
</div>

<!-- ── GRID DE TARJETAS ───────────────────────────────────── -->
<div class="users-grid" id="ventasGrid">
<% if (ventas.isEmpty()) { %>
  <div style="grid-column:1/-1;text-align:center;padding:60px 20px;color:#999;">
    <i class="fa-solid fa-inbox" style="font-size:48px;display:block;margin-bottom:16px;opacity:.4;"></i>
    <p>No hay ventas registradas.</p>
  </div>
<% } else { for (HashMap<String,String> v : ventas) {
     String estado      = v.getOrDefault("estado","completada");
     String badgeBg     = "completada".equals(estado) ? "#E1F5EE" : "#fde8e8";
     String badgeFg     = "completada".equals(estado) ? "#0F6E56"  : "#E24B4A";
     String clienteNom  = (v.get("cliente") != null && !"null".equals(v.get("cliente")))
                          ? v.get("cliente") : "Cliente General";
     String idV         = v.get("id");
%>
  <div class="user-card"
       data-cliente="<%= clienteNom.toLowerCase() %>"
       data-estado="<%= estado %>">

    <div class="user-top">
      <div style="flex:1;">
        <strong><i class="fa-solid fa-receipt"></i> Venta #<%= idV %></strong>
        <small style="display:block;color:#888;margin-top:2px;"><%= v.get("fecha") %></small>
      </div>
      <span style="font-size:11px;padding:3px 10px;border-radius:20px;font-weight:600;
                   background:<%= badgeBg %>;color:<%= badgeFg %>;">
        <%= "completada".equals(estado) ? "Completada" : "Anulada" %>
      </span>
    </div>

    <div class="user-info" style="margin-top:8px;">
      <p><i class="fa-solid fa-user"></i> <%= clienteNom %></p>
      <p style="margin:4px 0 0;">
        <i class="fa-solid fa-money-bill"></i>
        <strong style="color:#00a152;font-size:16px;">S/. <%= v.get("total") %></strong>
      </p>
    </div>

    <div style="display:flex;gap:8px;margin-top:12px;justify-content:flex-end;flex-wrap:wrap;">
      <button onclick="abrirDetalle('<%= idV %>')"
              style="background:none;border:1px solid #007bff;color:#007bff;
                     padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
        <i class="fa-solid fa-eye"></i> Ver detalle
      </button>
      <% if ("completada".equals(estado)) { %>
      <button onclick="abrirDetalle('<%= idV %>', true)"
              style="background:none;border:1px solid #7b2ff7;color:#7b2ff7;
                     padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
        <i class="fa-solid fa-print"></i> Recibo
      </button>
      <% if (puedeAnular) { %>
      <button onclick="confirmarAnulacion('<%= idV %>')"
              style="background:none;border:1px solid #e74c3c;color:#e74c3c;
                     padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
        <i class="fa-solid fa-ban"></i> Anular
      </button>
      <% } %>
      <% } %>
    </div>
  </div>
<% }} %>
</div>

<p id="sinVentas" style="display:none;text-align:center;color:#888;margin-top:30px;">
  No se encontraron ventas.
</p>


<!-- ══════════════════════════════════════════════════════════
     MODAL — CONFIRMACIÓN ANULACIÓN
══════════════════════════════════════════════════════════ -->
<div class="modal-overlay" id="modalAnular">
  <div class="modal" style="width:420px;">
    <h2 style="display:flex;align-items:center;gap:10px;color:#e74c3c;">
      <i class="fa-solid fa-ban"></i> Anular Venta
    </h2>
    <p style="color:#555;margin:12px 0 6px;">
      Esta acción <strong>no se puede deshacer</strong>. El sistema restaurará
      el stock de cada producto al inventario de la tienda.
    </p>
    <p style="font-size:13px;color:#888;margin-bottom:18px;">
      ¿Está seguro que desea anular la <strong id="anularLabel">Venta #?</strong>?
    </p>
    <form id="formAnular" method="POST" action="ServletAnularVenta">
      <input type="hidden" name="idVenta" id="anularIdVenta">
      <div class="modal-buttons">
        <button type="submit" class="btn-save"
                style="background:linear-gradient(135deg,#e74c3c,#c0392b);">
          <i class="fa-solid fa-ban"></i> Confirmar Anulación
        </button>
        <button type="button" class="btn-cancel" onclick="cerrarAnular()">
          Cancelar
        </button>
      </div>
    </form>
  </div>
</div>

<!-- ══════════════════════════════════════════════════════════
     MODAL 1 — POS (Nueva Venta)
══════════════════════════════════════════════════════════ -->
<div class="modal-overlay" id="modalPOS">
  <div class="modal" style="width:580px;max-height:90vh;overflow-y:auto;">
    <h2 style="display:flex;align-items:center;gap:10px;">
      <i class="fa-solid fa-cash-register" style="color:#007bff;"></i> Nueva Venta
    </h2>

    <!-- Cliente + Tipo de pago -->
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:4px;">
      <div>
        <label>Cliente</label>
        <select id="posCliente" style="width:100%;padding:9px;border-radius:10px;border:2px solid #eee;outline:none;">
          <option value="">Sin cliente / Público</option>
          <% for (HashMap<String,String> c : clientes) { %>
            <option value="<%= c.get("id") %>"><%= c.get("nombre") %></option>
          <% } %>
        </select>
      </div>
      <div>
        <label>Tipo de pago *</label>
        <select id="posTipoPago" style="width:100%;padding:9px;border-radius:10px;border:2px solid #eee;outline:none;">
          <option value="efectivo">💵 Efectivo</option>
          <option value="tarjeta">💳 Tarjeta</option>
        </select>
      </div>
    </div>

    <!-- Selector de producto -->
    <label style="margin-top:14px;">Agregar producto</label>
    <div style="display:flex;gap:8px;align-items:center;margin-top:6px;">
      <select id="selProducto" style="flex:1;padding:9px;border-radius:10px;border:2px solid #eee;outline:none;">
        <option value="">-- Seleccione producto --</option>
        <% for (HashMap<String,String> p : productos) { %>
          <option value="<%= p.get("id") %>"
                  data-precio="<%= p.get("precio") %>"
                  data-nombre="<%= p.get("nombre") %>">
            <%= p.get("nombre") %> &nbsp;·&nbsp; S/. <%= p.get("precio") %>
          </option>
        <% } %>
      </select>
      <button onclick="posAgregar()"
              style="background:linear-gradient(90deg,#00a152,#00d46a);color:#fff;
                     border:none;padding:9px 16px;border-radius:10px;cursor:pointer;
                     font-weight:600;white-space:nowrap;">
        <i class="fa-solid fa-plus"></i> Agregar
      </button>
    </div>

    <!-- Tabla carrito -->
    <div style="margin-top:16px;overflow-x:auto;">
      <table style="width:100%;border-collapse:collapse;font-size:14px;" id="tablaCarrito">
        <thead>
          <tr style="background:#f5f5f5;border-bottom:2px solid #eee;">
            <th style="padding:10px;text-align:left;">Producto</th>
            <th style="padding:10px;text-align:center;">Cant.</th>
            <th style="padding:10px;text-align:right;">P. Unit.</th>
            <th style="padding:10px;text-align:right;">Subtotal</th>
            <th style="padding:10px;"></th>
          </tr>
        </thead>
        <tbody id="carritoBody"></tbody>
      </table>
    </div>

    <!-- Total con IGV -->
    <div style="margin-top:14px;padding:14px;background:linear-gradient(135deg,#f8f8ff,#fff);
                border-radius:12px;border-left:4px solid #007bff;">
      <div style="display:flex;justify-content:space-between;font-size:12px;color:#888;margin-bottom:4px;">
        <span>Op. Gravada:</span><span>S/. <span id="posBase">0.00</span></span>
      </div>
      <div style="display:flex;justify-content:space-between;font-size:12px;color:#e67e22;font-weight:600;margin-bottom:8px;">
        <span>IGV (18%):</span><span>S/. <span id="posIgv">0.00</span></span>
      </div>
      <div style="display:flex;justify-content:space-between;align-items:center;">
        <span style="color:#555;font-size:13px;font-weight:600;">Total a pagar:</span>
        <span style="font-size:26px;font-weight:700;color:#00a152;">
          S/. <span id="posTotal">0.00</span>
        </span>
      </div>
    </div>

    <div class="modal-buttons" style="margin-top:18px;">
      <button onclick="posGuardar()" class="btn-save">
        <i class="fa-solid fa-check"></i> Guardar Venta
      </button>
      <button type="button" class="btn-cancel" onclick="cerrarPOS()">Cancelar</button>
    </div>
  </div>
</div>

<!-- Formulario oculto para enviar la venta -->
<form id="formVenta" method="POST" action="ServletGuardarVenta" style="display:none;">
  <input type="hidden" name="idCliente" id="fvCliente">
  <input type="hidden" name="tipoPago"  id="fvTipoPago">
  <input type="hidden" name="total"     id="fvTotal">
  <input type="hidden" name="numItems"  id="fvNumItems">
  <div id="fvItemsContainer"></div>
</form>


<!-- ══════════════════════════════════════════════════════════
     MODAL 2 — DETALLE / RECIBO  (uno por venta, pre-renderizado)
══════════════════════════════════════════════════════════ -->
<% for (HashMap<String,String> v : ventas) {
     String idV       = v.get("id");
     String clienteN  = (v.get("cliente") != null && !"null".equals(v.get("cliente")))
                        ? v.get("cliente") : "Cliente General";
     String estado    = v.getOrDefault("estado","activa");

     // buscar comprobante de esta venta
     String numComp = "—", tipoComp = "—", emisionComp = "—";
     for (HashMap<String,String> comp : comprobantes) {
       if (idV.equals(comp.get("idVenta"))) {
         numComp     = comp.getOrDefault("numero","—");
         tipoComp    = comp.getOrDefault("tipo","—");
         emisionComp = comp.getOrDefault("emision","—");
         break;
       }
     }
%>
<div class="modal-overlay" id="modalDetalle-<%= idV %>">
  <div class="modal" style="width:560px;max-height:90vh;overflow-y:auto;">

    <!-- cabecera imprimible -->
    <div id="recibo-<%= idV %>">
      <!-- logo y título -->
      <div style="text-align:center;margin-bottom:16px;">
        <img src="images/logo/logo.png" alt="SHOP-MAX"
             style="height:50px;margin-bottom:6px;"
             onerror="this.style.display='none'">
        <h3 style="margin:0;color:#007bff;">SHOP-MAX</h3>
        <p style="margin:2px 0;font-size:12px;color:#888;">Sistema de Ventas Retail</p>
        <hr style="border:1px dashed #ddd;margin:10px 0;">
      </div>

      <!-- datos comprobante -->
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px;
                  background:#f9f9f9;padding:12px;border-radius:10px;margin-bottom:14px;
                  font-size:13px;">
        <div><strong>Comprobante:</strong><br>
          <span style="text-transform:capitalize;color:#007bff;font-weight:600;">
            <%= tipoComp.equals("—") ? "Boleta" : tipoComp %> <%= numComp %>
          </span>
        </div>
        <div><strong>Venta #:</strong><br><%= idV %></div>
        <div><strong>Cliente:</strong><br><%= clienteN %></div>
        <div><strong>Estado:</strong><br>
          <span style="color:<%= "completada".equals(estado) ? "#0F6E56" : "#E24B4A" %>;">
            <%= "completada".equals(estado) ? "✅ Completada" : "❌ Anulada" %>
          </span>
        </div>
        <div><strong>Fecha:</strong><br><%= v.get("fecha") %></div>
        <div><strong>Tipo de pago:</strong><br><%= v.getOrDefault("tipoPago","—") %></div>
      </div>

      <!-- líneas de detalle -->
      <table style="width:100%;border-collapse:collapse;font-size:13px;margin-bottom:12px;">
        <thead>
          <tr style="background:#007bff;color:#fff;">
            <th style="padding:8px;text-align:left;border-radius:6px 0 0 0;">Producto</th>
            <th style="padding:8px;text-align:center;">Cant.</th>
            <th style="padding:8px;text-align:right;">P. Unit.</th>
            <th style="padding:8px;text-align:right;">Desc.</th>
            <th style="padding:8px;text-align:right;border-radius:0 6px 0 0;">Subtotal</th>
          </tr>
        </thead>
        <tbody>
          <%
            boolean hayDetalle = false;
            for (HashMap<String,String> d : detalles) {
              if (!idV.equals(d.get("idVenta"))) continue;
              hayDetalle = true;
              double sub = 0;
              try { sub = Double.parseDouble(d.get("subtotal")); } catch(Exception e){}
          %>
          <tr style="border-bottom:1px solid #f0f0f0;">
            <td style="padding:8px;"><strong><%= d.get("producto") %></strong></td>
            <td style="padding:8px;text-align:center;"><%= d.get("cantidad") %></td>
            <td style="padding:8px;text-align:right;">S/. <%= d.get("precioUnit") %></td>
            <td style="padding:8px;text-align:right;color:#e74c3c;">
              <%= !"0.00".equals(d.get("descuento")) && d.get("descuento") != null
                  ? "- S/. " + d.get("descuento") : "—" %>
            </td>
            <td style="padding:8px;text-align:right;font-weight:600;">
              S/. <%= String.format("%.2f", sub) %>
            </td>
          </tr>
          <% } %>
          <% if (!hayDetalle) { %>
          <tr>
            <td colspan="5" style="padding:14px;text-align:center;color:#999;">
              Sin detalle registrado
            </td>
          </tr>
          <% } %>
        </tbody>
        <tfoot>
          <%
            double vTotal = 0;
            try { vTotal = Double.parseDouble(v.get("total")); } catch(Exception e){}
            double vBase = vTotal / 1.18;
            double vIgv  = vTotal - vBase;
          %>
          <tr>
            <td colspan="4" style="padding:6px 10px;text-align:right;color:#666;font-size:12px;">
              Op. Gravada:
            </td>
            <td style="padding:6px 10px;text-align:right;color:#666;font-size:12px;">
              S/. <%= String.format("%.2f", vBase) %>
            </td>
          </tr>
          <tr>
            <td colspan="4" style="padding:6px 10px;text-align:right;color:#666;font-size:12px;">
              IGV (18%):
            </td>
            <td style="padding:6px 10px;text-align:right;color:#e67e22;font-size:12px;font-weight:600;">
              S/. <%= String.format("%.2f", vIgv) %>
            </td>
          </tr>
          <tr style="background:#f5f5f5;font-weight:700;border-top:2px solid #ddd;">
            <td colspan="4" style="padding:10px;text-align:right;font-size:14px;">
              TOTAL:
            </td>
            <td style="padding:10px;text-align:right;color:#00a152;font-size:16px;">
              S/. <%= String.format("%.2f", vTotal) %>
            </td>
          </tr>
        </tfoot>
      </table>

      <div style="text-align:center;font-size:11px;color:#aaa;margin-top:6px;">
        Gracias por su compra &nbsp;·&nbsp; SHOP-MAX
      </div>
    </div><!-- fin #recibo -->

    <!-- botones (no se imprimen) -->
    <div class="modal-buttons" style="margin-top:18px;">
      <button onclick="imprimirRecibo('<%= idV %>')" class="btn-save"
              style="background:linear-gradient(90deg,#7b2ff7,#007bff);">
        <i class="fa-solid fa-print"></i> Imprimir recibo
      </button>
      <button class="btn-cancel" onclick="cerrarDetalle('<%= idV %>')">Cerrar</button>
    </div>
  </div>
</div>
<% } %>




<!-- ══════════════════════════════════════════════════════════
     ÁREA DE IMPRESIÓN (invisible en pantalla, visible al imprimir)
══════════════════════════════════════════════════════════ -->
<div id="areaImpresion"></div>

<style>
/* Nunca display:none — Safari ignora el override de @media print sobre display.
   Se oculta con visibility + posición fuera de pantalla. */
#areaImpresion {
  visibility: hidden;
  position:   absolute;
  left:  -9999px;
  top:   0;
  width: 0;
  height: 0;
  overflow: hidden;
}

@media print {
  body * { visibility: hidden !important; }

  #areaImpresion,
  #areaImpresion * {
    visibility: visible !important;
  }

  #areaImpresion {
    position:   fixed !important;
    top:        0    !important;
    left:       0    !important;
    width:      100% !important;
    height:     auto !important;
    overflow:   visible !important;
    padding:    28px 32px !important;
    background: #fff !important;
    font-family: Arial, sans-serif;
    font-size:   13px;
    color:       #333;
  }

  @page { margin: 10mm; }
}
</style>

<!-- ══════════════════════════════════════════════════════════
     JAVASCRIPT
══════════════════════════════════════════════════════════ -->
<script>
/* ── ANULACIÓN ───────────────────────────── */
function confirmarAnulacion(idVenta) {
  document.getElementById("anularIdVenta").value = idVenta;
  document.getElementById("anularLabel").textContent = "Venta #" + idVenta;
  document.getElementById("modalAnular").style.display = "flex";
}
function cerrarAnular() {
  document.getElementById("modalAnular").style.display = "none";
}
document.getElementById("modalAnular").addEventListener("click", function(e) {
  if (e.target === this) cerrarAnular();
});

/* ── POS ─────────────────────────────────── */
let carrito = [];

function abrirPOS() {
  carrito = [];
  renderCarrito();
  document.getElementById("modalPOS").style.display = "flex";
}
function cerrarPOS() {
  document.getElementById("modalPOS").style.display = "none";
}
document.getElementById("modalPOS").addEventListener("click", function(e) {
  if (e.target === this) cerrarPOS();
});

function posAgregar() {
  const sel   = document.getElementById("selProducto");
  const id    = sel.value;
  if (!id) { alert("Selecciona un producto"); return; }
  const nombre = sel.options[sel.selectedIndex].dataset.nombre;
  const precio = parseFloat(sel.options[sel.selectedIndex].dataset.precio);

  const ya = carrito.find(i => i.id === id);
  if (ya) { ya.cantidad++; }
  else     { carrito.push({ id, nombre, precio, cantidad: 1 }); }

  sel.value = "";
  renderCarrito();
}

function renderCarrito() {
  const tbody = document.getElementById("carritoBody");
  tbody.innerHTML = "";
  let total = 0;

  carrito.forEach((item, idx) => {
    const sub = item.precio * item.cantidad;
    total += sub;
    const tr = document.createElement("tr");
    tr.style.borderBottom = "1px solid #f0f0f0";
    tr.innerHTML =
      '<td style="padding:8px;">' + item.nombre + '</td>' +
      '<td style="padding:8px;text-align:center;">' +
        '<input type="number" min="1" value="' + item.cantidad + '"' +
               ' onchange="cambiarCantidad(' + idx + ',this.value)"' +
               ' style="width:55px;text-align:center;border:1px solid #ddd;border-radius:6px;padding:4px;">' +
      '</td>' +
      '<td style="padding:8px;text-align:right;">S/. ' + item.precio.toFixed(2) + '</td>' +
      '<td style="padding:8px;text-align:right;font-weight:600;">S/. ' + sub.toFixed(2) + '</td>' +
      '<td style="padding:8px;text-align:center;">' +
        '<button onclick="quitarItem(' + idx + ')"' +
                ' style="background:none;border:none;color:#e74c3c;cursor:pointer;font-size:16px;">✕</button>' +
      '</td>';
    tbody.appendChild(tr);
  });

  const base = total / 1.18;
  const igv  = total - base;
  document.getElementById("posTotal").textContent = total.toFixed(2);
  document.getElementById("posBase").textContent  = base.toFixed(2);
  document.getElementById("posIgv").textContent   = igv.toFixed(2);
}

function cambiarCantidad(idx, val) {
  carrito[idx].cantidad = Math.max(1, parseInt(val) || 1);
  renderCarrito();
}
function quitarItem(idx) {
  carrito.splice(idx, 1);
  renderCarrito();
}

function posGuardar() {
  if (carrito.length === 0) { alert("El carrito está vacío"); return; }
  const total = carrito.reduce((s,i) => s + i.precio * i.cantidad, 0);
  document.getElementById("fvCliente").value  = document.getElementById("posCliente").value;
  document.getElementById("fvTipoPago").value = document.getElementById("posTipoPago").value;
  document.getElementById("fvTotal").value    = total.toFixed(2);
  document.getElementById("fvNumItems").value = carrito.length;

  const container = document.getElementById("fvItemsContainer");
  container.innerHTML = "";
  carrito.forEach((item, i) => {
    const mkInput = (name, val) => {
      const el = document.createElement("input");
      el.type  = "hidden";
      el.name  = name;
      el.value = val;
      container.appendChild(el);
    };
    mkInput("item_id_"     + i, item.id);
    mkInput("item_cant_"   + i, item.cantidad);
    mkInput("item_precio_" + i, item.precio.toFixed(2));
  });

  document.getElementById("formVenta").submit();
}

/* ── DETALLE ─────────────────────────────── */
function abrirDetalle(id, imprimir) {
  const m = document.getElementById("modalDetalle-" + id);
  if (!m) return;
  m.style.display = "flex";
  if (imprimir) setTimeout(() => imprimirRecibo(id), 300);
}
function cerrarDetalle(id) {
  document.getElementById("modalDetalle-" + id).style.display = "none";
}

// Cerrar al click fuera
document.querySelectorAll('[id^="modalDetalle-"]').forEach(m => {
  m.addEventListener("click", function(e) {
    if (e.target === this) this.style.display = "none";
  });
});

/* ── IMPRESIÓN ───────────────────────────── */
function imprimirRecibo(id) {
  const contenido = document.getElementById("recibo-" + id).innerHTML;
  const area = document.getElementById("areaImpresion");
  area.innerHTML = contenido;
  // Safari requiere que el elemento esté visiblemente en el DOM antes de print()
  area.style.cssText = "position:fixed;top:0;left:0;width:100%;height:auto;" +
                       "overflow:visible;visibility:visible;background:#fff;" +
                       "padding:28px 32px;font-family:Arial,sans-serif;font-size:13px;color:#333;z-index:99999;";
  window.print();
  area.style.cssText = "visibility:hidden;position:absolute;left:-9999px;top:0;width:0;height:0;overflow:hidden;";
  area.innerHTML = "";
}

/* ── FILTROS ─────────────────────────────── */
function filtrarVentas() {
  const q      = document.getElementById("searchVenta").value.toLowerCase();
  const estado = document.getElementById("estadoFilter").value;
  const cards  = document.querySelectorAll("#ventasGrid .user-card");
  let visibles = 0;
  cards.forEach(c => {
    const ok = c.dataset.cliente.includes(q) &&
               (!estado || c.dataset.estado === estado);
    c.style.display = ok ? "" : "none";
    if (ok) visibles++;
  });
  document.getElementById("sinVentas").style.display = visibles === 0 ? "block" : "none";
}
</script>
