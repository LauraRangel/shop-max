<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap,java.util.ArrayList"%>

<%
  ArrayList<HashMap<String,String>> productos = (ArrayList<HashMap<String,String>>) request.getAttribute("listaProductos");
  ArrayList<HashMap<String,String>> categorias = (ArrayList<HashMap<String,String>>) request.getAttribute("listaCategorias");
  if (productos == null) productos = new ArrayList<>();
  if (categorias == null) categorias = new ArrayList<>();

  // esAdmin, esGerente, esCajero already in scope from dashboard.jsp (static include)
  boolean puedeGestionar = esAdmin || esGerente;

  int critico = 0, bajo = 0, normal = 0;
  for (HashMap<String,String> p : productos) {
    try {
      int s = Integer.parseInt(p.getOrDefault("stock",  "0"));
      int m = Integer.parseInt(p.getOrDefault("minimo", "5"));
      if      (s < m)     critico++;
      else if (s < m + 3) bajo++;
      else                normal++;
    } catch (Exception e) {}
  }
%>

<!-- HEADER -->
<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-box"></i> Gestión de Inventario
  </h2>
  <div style="display:flex;gap:10px;">
    <% if (puedeGestionar) { %>
    <button class="btn-add-user"
            style="background:linear-gradient(90deg,#00a152,#00d46a);"
            onclick="abrirModalEntrada(null,null)">
      <i class="fa-solid fa-arrow-down"></i> Entrada de Stock
    </button>
    <button class="btn-add-user" onclick="abrirModalProducto()">
      <i class="fa-solid fa-plus"></i> Nuevo Producto
    </button>
    <% } %>
  </div>
</div>

<!-- ALERTA STOCK CRÍTICO -->
<% if (critico > 0) { %>
<div style="background:linear-gradient(90deg,#fff3e0,#ffcc80); border-left:4px solid #ff9800;
            border-radius:8px; padding:12px 18px; margin-bottom:18px;
            display:flex; align-items:center; gap:12px;">
  <i class="fa-solid fa-triangle-exclamation" style="color:#e65100; font-size:18px;"></i>
  <span style="font-weight:600; color:#e65100;"><%= critico %> producto(s) con stock crítico</span>
  <span style="color:#bf360c; font-size:13px;">— por debajo del mínimo configurado</span>
</div>
<% } %>

<!-- STATS -->
<div class="users-stats">
  <div class="stat-card total">
    <p><i class="fa-solid fa-cubes"></i> Total Productos</p>
    <h3><%= productos.size() %></h3>
  </div>
  <div class="stat-card active">
    <p><i class="fa-solid fa-circle-check"></i> Stock Normal</p>
    <h3><%= normal %></h3>
  </div>
  <div class="stat-card inactive">
    <p><i class="fa-solid fa-triangle-exclamation"></i> Stock Bajo / Crítico</p>
    <h3><%= bajo + critico %></h3>
  </div>
</div>

<!-- FILTROS -->
<div class="users-filters">
  <div class="search-box">
    <i class="fa fa-search"></i>
    <input type="text" id="searchProducto" placeholder="Buscar productos..." oninput="filtrarProductos()">
  </div>
  <select id="categoriaFilter" onchange="filtrarProductos()">
    <option value="">🏷️ Todas las categorías</option>
    <% for (HashMap<String,String> cat : categorias) { %>
    <option value="<%= cat.get("id") %>"><%= cat.get("nombre") %></option>
    <% } %>
  </select>
  <select id="estadoStockFilter" onchange="filtrarProductos()">
    <option value="">📊 Todos los estados</option>
    <option value="normal">✅ Stock Normal</option>
    <option value="bajo">⚠️ Stock Bajo</option>
    <option value="critico">🔴 Stock Crítico</option>
  </select>
</div>

<!-- GRID DE TARJETAS -->
<div class="users-grid" id="productosGrid">
  <% if (productos.isEmpty()) { %>
    <div style="grid-column:1/-1; text-align:center; padding:60px 20px; color:#999;">
      <i class="fa-solid fa-inbox" style="font-size:48px; margin-bottom:20px; display:block; opacity:0.5;"></i>
      <p>No hay productos registrados</p>
    </div>
  <% } else {
       for (HashMap<String,String> p : productos) {
         int    stock  = Integer.parseInt(p.getOrDefault("stock",  "0"));
         int    minimo = Integer.parseInt(p.getOrDefault("minimo", "5"));
         double precio = 0;
         try { precio = Double.parseDouble(p.getOrDefault("precio","0")); } catch (Exception e) {}
         String precioFmt = String.format("%.2f", precio);

         String estado, estadoColor, estadoFont, icono;
         if (stock < minimo) {
           estado = "critico"; estadoColor = "#fde8e8"; estadoFont = "#E24B4A"; icono = "circle-xmark";
         } else if (stock < minimo + 3) {
           estado = "bajo"; estadoColor = "#fff3e0"; estadoFont = "#ff9800"; icono = "triangle-exclamation";
         } else {
           estado = "normal"; estadoColor = "#E1F5EE"; estadoFont = "#0F6E56"; icono = "circle-check";
         }

         String nombreEsc  = p.get("nombre").replace("'", "\\'").replace("\"", "&quot;");
         String codigoEsc  = p.get("codigo").replace("'", "\\'");
  %>
    <div class="user-card"
         data-producto="<%= p.get("nombre").toLowerCase() %>"
         data-estado="<%= estado %>"
         data-categoria="<%= p.get("idCategoria") %>">

      <div class="user-top">
        <div style="flex:1; min-width:0;">
          <strong style="font-size:14px; display:block;">
            <i class="fa-solid fa-barcode"></i> <%= p.get("codigo") %>
          </strong>
          <small style="color:#888;"><%= p.get("categoria") %></small>
        </div>
        <span style="font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600;
                     background:<%= estadoColor %>; color:<%= estadoFont %>; white-space:nowrap;">
          <i class="fa-solid fa-<%= icono %>"></i> <%= estado.toUpperCase() %>
        </span>
      </div>

      <div class="user-info" style="margin-top:8px;">
        <p><strong style="font-size:15px;"><%= p.get("nombre") %></strong></p>
        <p style="margin:8px 0;">
          <i class="fa-solid fa-warehouse"></i> Stock:
          <strong style="font-size:16px;"><%= stock %></strong>
          <span style="color:#aaa; font-size:12px; margin-left:6px;">mín. <%= minimo %></span>
        </p>
        <p style="margin:0; color:#555; font-size:13px;">
          <i class="fa-solid fa-tag"></i> Precio:
          <strong style="color:#007bff;">S/. <%= precioFmt %></strong>
        </p>
      </div>

      <div style="display:flex; gap:6px; margin-top:12px; justify-content:flex-end; flex-wrap:wrap;">
        <% if (puedeGestionar) { %>
        <button onclick="abrirModalEntrada('<%= p.get("id") %>','<%= nombreEsc %>')"
                title="Registrar entrada de stock"
                style="background:linear-gradient(90deg,#00a152,#00d46a); color:white; border:none;
                       padding:6px 10px; border-radius:6px; cursor:pointer; font-size:11px; font-weight:600;">
          <i class="fa-solid fa-arrow-down"></i> Entrada
        </button>
        <button onclick="abrirModalEditar('<%= p.get("id") %>','<%= p.get("idCategoria") %>','<%= codigoEsc %>','<%= nombreEsc %>','<%= precioFmt %>','<%= minimo %>')"
                title="Editar producto"
                style="background:linear-gradient(90deg,#007bff,#0056d2); color:white; border:none;
                       padding:6px 10px; border-radius:6px; cursor:pointer; font-size:11px; font-weight:600;">
          <i class="fa-solid fa-pen"></i> Editar
        </button>
        <% } %>
        <% if (esAdmin) { %>
        <button onclick="confirmarEliminar('<%= p.get("id") %>','<%= nombreEsc %>')"
                title="Eliminar producto"
                style="background:linear-gradient(90deg,#e53935,#c62828); color:white; border:none;
                       padding:6px 10px; border-radius:6px; cursor:pointer; font-size:11px; font-weight:600;">
          <i class="fa-solid fa-trash"></i>
        </button>
        <% } %>
      </div>
    </div>
  <% }} %>
</div>

<!-- MODAL: Entrada de Stock -->
<div class="modal-overlay" id="modalEntrada">
  <div class="modal" style="width:460px;">
    <form method="POST" action="ServletEntradaStock">
      <h2><i class="fa-solid fa-arrow-down" style="color:#00a152;"></i> Entrada de Stock</h2>

      <label>Producto *</label>
      <select name="idProducto" id="entradaProductoId" required>
        <option value="">-- Seleccione un producto --</option>
        <% for (HashMap<String,String> p : productos) { %>
          <option value="<%= p.get("id") %>">
            <%= p.get("nombre") %> (<%= p.get("codigo") %>)
          </option>
        <% } %>
      </select>

      <label>Cantidad a ingresar *</label>
      <input type="number" name="cantidad" placeholder="0" required min="1">

      <div class="modal-buttons">
        <button type="submit" class="btn-save">
          <i class="fa-solid fa-check"></i> Registrar
        </button>
        <button type="button" class="btn-cancel" onclick="cerrarModalEntrada()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- MODAL: Nuevo Producto -->
<div class="modal-overlay" id="modalProducto">
  <div class="modal" style="width:520px;">
    <form method="POST" action="ServletGuardarProducto">
      <h2><i class="fa-solid fa-box-open" style="color:#007bff;"></i> Nuevo Producto</h2>

      <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
        <div>
          <label>Código *</label>
          <input type="text" name="codigo" placeholder="Ej: ELEC-003" required maxlength="50">
        </div>
        <div>
          <label>Categoría *</label>
          <select name="idCategoria" required>
            <option value="">Seleccione...</option>
            <% for (HashMap<String,String> cat : categorias) { %>
              <option value="<%= cat.get("id") %>"><%= cat.get("nombre") %></option>
            <% } %>
          </select>
        </div>
      </div>

      <label>Nombre del producto *</label>
      <input type="text" name="nombre" placeholder="Ej: Smartphone Samsung A15" required maxlength="150">

      <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
        <div>
          <label>Precio de venta (S/.) *</label>
          <input type="number" name="precio" placeholder="0.00" required min="0" step="0.01">
        </div>
        <div>
          <label>Stock mínimo</label>
          <input type="number" name="stockMinimo" placeholder="5" min="0" value="5">
        </div>
      </div>

      <div class="modal-buttons">
        <button type="submit" class="btn-save"><i class="fa-solid fa-check"></i> Guardar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModalProducto()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- MODAL: Editar Producto -->
<div class="modal-overlay" id="modalEditar">
  <div class="modal" style="width:520px;">
    <form method="POST" action="ServletEditarProducto">
      <h2><i class="fa-solid fa-pen" style="color:#007bff;"></i> Editar Producto</h2>
      <input type="hidden" name="idProducto" id="editIdProducto">

      <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
        <div>
          <label>Código *</label>
          <input type="text" name="codigo" id="editCodigo" required maxlength="50">
        </div>
        <div>
          <label>Categoría *</label>
          <select name="idCategoria" id="editIdCategoria" required>
            <option value="">Seleccione...</option>
            <% for (HashMap<String,String> cat : categorias) { %>
              <option value="<%= cat.get("id") %>"><%= cat.get("nombre") %></option>
            <% } %>
          </select>
        </div>
      </div>

      <label>Nombre del producto *</label>
      <input type="text" name="nombre" id="editNombreProducto" required maxlength="150">

      <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
        <div>
          <label>Precio de venta (S/.) *</label>
          <input type="number" name="precio" id="editPrecio" required min="0" step="0.01">
        </div>
        <div>
          <label>Stock mínimo</label>
          <input type="number" name="stockMinimo" id="editStockMinimo" min="0">
        </div>
      </div>

      <div class="modal-buttons">
        <button type="submit" class="btn-save"><i class="fa-solid fa-check"></i> Actualizar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModalEditar()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- MODAL: Confirmar Eliminación -->
<div class="modal-overlay" id="modalEliminar">
  <div class="modal" style="width:420px; text-align:center;">
    <form method="POST" action="ServletEliminarProducto">
      <input type="hidden" name="idProducto" id="eliminarIdProducto">
      <div style="font-size:48px; margin-bottom:12px; color:#e53935;">
        <i class="fa-solid fa-trash"></i>
      </div>
      <h2 style="margin-bottom:8px;">Eliminar Producto</h2>
      <p style="color:#666; margin-bottom:20px;">
        ¿Estás seguro de eliminar <strong id="eliminarNombreProducto"></strong>?
        Esta acción no se puede deshacer.
      </p>
      <div class="modal-buttons">
        <button type="submit" class="btn-save"
                style="background:linear-gradient(90deg,#e53935,#c62828);">
          <i class="fa-solid fa-trash"></i> Eliminar
        </button>
        <button type="button" class="btn-cancel" onclick="cerrarModalEliminar()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<script>
// --- Entrada de Stock ---
function abrirModalEntrada(id, nombre) {
  if (id) document.getElementById("entradaProductoId").value = id;
  document.getElementById("modalEntrada").style.display = "flex";
}
function cerrarModalEntrada() { document.getElementById("modalEntrada").style.display = "none"; }
document.getElementById("modalEntrada").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalEntrada();
});

// --- Nuevo Producto ---
function abrirModalProducto()  { document.getElementById("modalProducto").style.display = "flex"; }
function cerrarModalProducto() { document.getElementById("modalProducto").style.display = "none"; }
document.getElementById("modalProducto").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalProducto();
});

// --- Editar Producto ---
function abrirModalEditar(id, idCat, codigo, nombre, precio, minimo) {
  document.getElementById("editIdProducto").value     = id;
  document.getElementById("editCodigo").value         = codigo;
  document.getElementById("editNombreProducto").value = nombre;
  document.getElementById("editPrecio").value         = precio;
  document.getElementById("editStockMinimo").value    = minimo;
  var sel = document.getElementById("editIdCategoria");
  for (var i = 0; i < sel.options.length; i++) {
    if (sel.options[i].value === idCat) { sel.selectedIndex = i; break; }
  }
  document.getElementById("modalEditar").style.display = "flex";
}
function cerrarModalEditar() { document.getElementById("modalEditar").style.display = "none"; }
document.getElementById("modalEditar").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalEditar();
});

// --- Eliminar ---
function confirmarEliminar(id, nombre) {
  document.getElementById("eliminarIdProducto").value        = id;
  document.getElementById("eliminarNombreProducto").textContent = nombre;
  document.getElementById("modalEliminar").style.display     = "flex";
}
function cerrarModalEliminar() { document.getElementById("modalEliminar").style.display = "none"; }
document.getElementById("modalEliminar").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalEliminar();
});

// --- Filtros ---
function filtrarProductos() {
  var search = document.getElementById("searchProducto").value.toLowerCase();
  var catId  = document.getElementById("categoriaFilter").value;
  var estado = document.getElementById("estadoStockFilter").value;
  var cards  = document.querySelectorAll("#productosGrid .user-card");
  cards.forEach(function(card) {
    var matchSearch = card.getAttribute("data-producto").includes(search);
    var matchCat    = !catId  || card.getAttribute("data-categoria") === catId;
    var matchEstado = !estado || card.getAttribute("data-estado")    === estado;
    card.style.display = (matchSearch && matchCat && matchEstado) ? "" : "none";
  });
}
</script>
