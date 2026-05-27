<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap,java.util.ArrayList"%>

<%
  ArrayList<HashMap<String,String>> proveedores =
      (ArrayList<HashMap<String,String>>) request.getAttribute("listaProveedores");
  if (proveedores == null) proveedores = new ArrayList<>();
%>

<!-- HEADER -->
<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-truck"></i> Gestión de Proveedores
  </h2>
  <button class="btn-add-user" onclick="abrirModalProveedor()">
    <i class="fa-solid fa-plus"></i> Nuevo Proveedor
  </button>
</div>

<!-- STATS -->
<div class="users-stats">
  <div class="stat-card total">
    <p><i class="fa-solid fa-building"></i> Total Proveedores</p>
    <h3><%= proveedores.size() %></h3>
  </div>
  <div class="stat-card active">
    <p><i class="fa-solid fa-id-badge"></i> Con RUC</p>
    <h3><%
      int conRuc = 0;
      for (HashMap<String,String> p : proveedores)
        if (p.get("ruc") != null && !p.get("ruc").isEmpty()) conRuc++;
      out.print(conRuc);
    %></h3>
  </div>
  <div class="stat-card inactive">
    <p><i class="fa-solid fa-envelope"></i> Con Email</p>
    <h3><%
      int conEmail = 0;
      for (HashMap<String,String> p : proveedores)
        if (p.get("email") != null && !p.get("email").isEmpty()) conEmail++;
      out.print(conEmail);
    %></h3>
  </div>
</div>

<!-- FILTROS -->
<div class="users-filters">
  <div class="search-box">
    <i class="fa fa-search"></i>
    <input type="text" id="searchProveedor" placeholder="Buscar por razón social, RUC o contacto..." oninput="filtrarProveedores()">
  </div>
</div>

<!-- GRID DE TARJETAS -->
<div class="users-grid" id="proveedoresGrid">
  <% if (proveedores.isEmpty()) { %>
    <div style="grid-column:1/-1;text-align:center;padding:60px 20px;color:#999;">
      <i class="fa-solid fa-inbox" style="font-size:48px;display:block;margin-bottom:16px;opacity:.4;"></i>
      <p>No hay proveedores registrados aún.</p>
    </div>
  <% } else { for (HashMap<String,String> p : proveedores) {
       String letra = (p.get("nombre") != null && !p.get("nombre").isEmpty())
                      ? String.valueOf(p.get("nombre").charAt(0)).toUpperCase() : "?";
  %>
    <div class="user-card"
         data-nombre="<%= p.get("nombre") != null ? p.get("nombre").toLowerCase() : "" %>"
         data-ruc="<%= p.get("ruc") != null ? p.get("ruc") : "" %>"
         data-contacto="<%= p.get("contacto") != null ? p.get("contacto").toLowerCase() : "" %>">

      <div class="user-top">
        <div class="avatar" style="background:linear-gradient(90deg,#ff9800,#f44336);">
          <%= letra %>
        </div>
        <div class="user-info" style="flex:1;">
          <strong><%= p.get("nombre") %></strong>
          <small style="color:#888;">RUC: <%= p.get("ruc") != null ? p.get("ruc") : "—" %></small>
        </div>
      </div>

      <div class="user-info" style="margin-top:8px;">
        <p><i class="fa-solid fa-user-tie"></i> <%= p.get("contacto") != null ? p.get("contacto") : "—" %></p>
        <p><i class="fa-solid fa-phone"></i> <%= p.get("telefono") != null ? p.get("telefono") : "—" %></p>
        <p><i class="fa-solid fa-envelope"></i> <%= p.get("email") != null ? p.get("email") : "—" %></p>
      </div>

      <div style="display:flex;gap:8px;margin-top:12px;justify-content:flex-end;">
        <button onclick="abrirModalEditarProveedor('<%= p.get("id") %>','<%= p.get("nombre") %>','<%= p.get("ruc") %>','<%= p.get("contacto") %>','<%= p.get("telefono") %>','<%= p.get("email") %>')"
                style="background:none;border:1px solid #007bff;color:#007bff;padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
          <i class="fa-solid fa-pen"></i> Editar
        </button>
        <button onclick="confirmarEliminarProveedor('<%= p.get("id") %>','<%= p.get("nombre") %>')"
                style="background:none;border:1px solid #E24B4A;color:#E24B4A;padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
          <i class="fa-solid fa-trash"></i> Eliminar
        </button>
      </div>
    </div>
  <% }} %>
</div>

<p id="sinProveedores" style="display:none;text-align:center;color:#888;margin-top:30px;">No se encontraron proveedores.</p>

<!-- MODAL: AGREGAR PROVEEDOR -->
<div class="modal-overlay" id="modalProveedor">
  <div class="modal" style="width:500px;">
    <form method="POST" action="ServletGuardarProveedor">
      <h2><i class="fa-solid fa-building-circle-arrow-right" style="color:#007bff;"></i> Nuevo Proveedor</h2>

      <label>Razón Social *</label>
      <input type="text" name="razonSocial" placeholder="Ej: Samsung Perú S.A.C." required maxlength="150">

      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
        <div>
          <label>RUC</label>
          <input type="text" name="ruc" placeholder="20512345678" maxlength="11"
                 pattern="[0-9]{11}" title="El RUC debe tener 11 dígitos">
        </div>
        <div>
          <label>Contacto</label>
          <input type="text" name="contacto" placeholder="Nombre del responsable" maxlength="100">
        </div>
      </div>

      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
        <div>
          <label>Teléfono</label>
          <input type="text" name="telefono" placeholder="014567890" maxlength="15">
        </div>
        <div>
          <label>Email</label>
          <input type="email" name="email" placeholder="proveedor@empresa.com" maxlength="100">
        </div>
      </div>

      <div class="modal-buttons">
        <button type="submit" class="btn-save"><i class="fa-solid fa-check"></i> Guardar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModalProveedor()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- MODAL: EDITAR PROVEEDOR -->
<div class="modal-overlay" id="modalEditarProveedor">
  <div class="modal" style="width:500px;">
    <form method="POST" action="ServletEditarProveedor">
      <h2><i class="fa-solid fa-building-circle-arrow-right" style="color:#007bff;"></i> Editar Proveedor</h2>
      <input type="hidden" name="id" id="editProveedorId">

      <label>Razón Social *</label>
      <input type="text" name="razonSocial" id="editProveedorNombre" required maxlength="150">

      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
        <div>
          <label>RUC</label>
          <input type="text" name="ruc" id="editProveedorRuc" maxlength="11">
        </div>
        <div>
          <label>Contacto</label>
          <input type="text" name="contacto" id="editProveedorContacto" maxlength="100">
        </div>
      </div>

      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
        <div>
          <label>Teléfono</label>
          <input type="text" name="telefono" id="editProveedorTel" maxlength="15">
        </div>
        <div>
          <label>Email</label>
          <input type="email" name="email" id="editProveedorEmail" maxlength="100">
        </div>
      </div>

      <div class="modal-buttons">
        <button type="submit" class="btn-save"><i class="fa-solid fa-check"></i> Actualizar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModalEditarProveedor()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- FORM OCULTO: ELIMINAR -->
<form id="formEliminarProveedor" method="POST" action="ServletEliminarProveedor" style="display:none;">
  <input type="hidden" name="id" id="eliminarProveedorId">
</form>

<script>
function abrirModalProveedor()        { document.getElementById("modalProveedor").style.display = "flex"; }
function cerrarModalProveedor()       { document.getElementById("modalProveedor").style.display = "none"; }
function cerrarModalEditarProveedor() { document.getElementById("modalEditarProveedor").style.display = "none"; }

document.getElementById("modalProveedor").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalProveedor();
});
document.getElementById("modalEditarProveedor").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalEditarProveedor();
});

function abrirModalEditarProveedor(id, nombre, ruc, contacto, telefono, email) {
  document.getElementById("editProveedorId").value       = id;
  document.getElementById("editProveedorNombre").value   = nombre;
  document.getElementById("editProveedorRuc").value      = ruc !== "null" ? ruc : "";
  document.getElementById("editProveedorContacto").value = contacto !== "null" ? contacto : "";
  document.getElementById("editProveedorTel").value      = telefono !== "null" ? telefono : "";
  document.getElementById("editProveedorEmail").value    = email !== "null" ? email : "";
  document.getElementById("modalEditarProveedor").style.display = "flex";
}

function confirmarEliminarProveedor(id, nombre) {
  if (confirm("¿Eliminar al proveedor " + nombre + "?\nEsta acción no se puede deshacer.")) {
    document.getElementById("eliminarProveedorId").value = id;
    document.getElementById("formEliminarProveedor").submit();
  }
}

function filtrarProveedores() {
  const q = document.getElementById("searchProveedor").value.toLowerCase();
  const cards = document.querySelectorAll("#proveedoresGrid .user-card");
  let visibles = 0;
  cards.forEach(card => {
    const match = card.dataset.nombre.includes(q)
                || card.dataset.ruc.includes(q)
                || card.dataset.contacto.includes(q);
    card.style.display = match ? "" : "none";
    if (match) visibles++;
  });
  document.getElementById("sinProveedores").style.display = visibles === 0 ? "block" : "none";
}
</script>
