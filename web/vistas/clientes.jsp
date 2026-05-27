<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap,java.util.ArrayList"%>

<%
  ArrayList<HashMap<String,String>> clientes =
      (ArrayList<HashMap<String,String>>) request.getAttribute("listaClientes");
  if (clientes == null) clientes = new ArrayList<>();
%>

<!-- HEADER -->
<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-users"></i> Gestión de Clientes
  </h2>
  <button class="btn-add-user" onclick="abrirModalCliente()">
    <i class="fa-solid fa-plus"></i> Nuevo Cliente
  </button>
</div>

<!-- STATS -->
<div class="users-stats">
  <div class="stat-card total">
    <p><i class="fa-solid fa-users"></i> Total Clientes</p>
    <h3><%= clientes.size() %></h3>
  </div>
  <div class="stat-card active">
    <p><i class="fa-solid fa-id-card"></i> Con Documento</p>
    <h3><%
      int conDoc = 0;
      for (HashMap<String,String> c : clientes)
        if (c.get("documento") != null && !c.get("documento").isEmpty()) conDoc++;
      out.print(conDoc);
    %></h3>
  </div>
  <div class="stat-card inactive">
    <p><i class="fa-solid fa-calendar"></i> Registrados hoy</p>
    <h3><%
      String hoy = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
      int hoyCount = 0;
      for (HashMap<String,String> c : clientes)
        if (hoy.equals(c.get("fecha"))) hoyCount++;
      out.print(hoyCount);
    %></h3>
  </div>
</div>

<!-- FILTROS -->
<div class="users-filters">
  <div class="search-box">
    <i class="fa fa-search"></i>
    <input type="text" id="searchCliente" placeholder="Buscar por nombre, email o documento..." oninput="filtrarClientes()">
  </div>
</div>

<!-- GRID DE TARJETAS -->
<div class="users-grid" id="clientesGrid">
  <% if (clientes.isEmpty()) { %>
    <div style="grid-column:1/-1;text-align:center;padding:60px 20px;color:#999;">
      <i class="fa-solid fa-inbox" style="font-size:48px;display:block;margin-bottom:16px;opacity:.4;"></i>
      <p>No hay clientes registrados aún.</p>
    </div>
  <% } else { for (HashMap<String,String> c : clientes) {
       String letra = (c.get("nombre") != null && !c.get("nombre").isEmpty())
                      ? String.valueOf(c.get("nombre").charAt(0)).toUpperCase() : "?";
  %>
    <div class="user-card"
         data-nombre="<%= c.get("nombre") != null ? c.get("nombre").toLowerCase() : "" %>"
         data-email="<%= c.get("email") != null ? c.get("email").toLowerCase() : "" %>"
         data-doc="<%= c.get("documento") != null ? c.get("documento") : "" %>">

      <div class="user-top">
        <div class="avatar"><%= letra %></div>
        <div class="user-info" style="flex:1;">
          <strong><%= c.get("nombre") %></strong>
          <small style="color:#888;">DNI/RUC: <%= c.get("documento") != null ? c.get("documento") : "—" %></small>
        </div>
      </div>

      <div class="user-info" style="margin-top:8px;">
        <p><i class="fa-solid fa-envelope"></i> <%= c.get("email") != null ? c.get("email") : "—" %></p>
        <p><i class="fa-solid fa-phone"></i> <%= c.get("telefono") != null ? c.get("telefono") : "—" %></p>
        <p><i class="fa-solid fa-calendar-days"></i> Desde: <%= c.get("fecha") != null ? c.get("fecha") : "—" %></p>
      </div>

      <div style="display:flex;gap:8px;margin-top:12px;justify-content:flex-end;">
        <button onclick="abrirModalEditarCliente('<%= c.get("id") %>','<%= c.get("nombre") %>','<%= c.get("email") %>','<%= c.get("telefono") %>','<%= c.get("documento") %>')"
                style="background:none;border:1px solid #007bff;color:#007bff;padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
          <i class="fa-solid fa-pen"></i> Editar
        </button>
        <button onclick="confirmarEliminarCliente('<%= c.get("id") %>','<%= c.get("nombre") %>')"
                style="background:none;border:1px solid #E24B4A;color:#E24B4A;padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
          <i class="fa-solid fa-trash"></i> Eliminar
        </button>
      </div>
    </div>
  <% }} %>
</div>

<p id="sinClientes" style="display:none;text-align:center;color:#888;margin-top:30px;">No se encontraron clientes.</p>

<!-- MODAL: AGREGAR CLIENTE -->
<div class="modal-overlay" id="modalCliente">
  <div class="modal" style="width:480px;">
    <form method="POST" action="ServletGuardarCliente">
      <h2><i class="fa-solid fa-user-plus" style="color:#007bff;"></i> Nuevo Cliente</h2>

      <label>Nombre completo *</label>
      <input type="text" name="nombre" placeholder="Ej: Juan Pérez García" required maxlength="150">

      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
        <div>
          <label>DNI / Documento *</label>
          <input type="text" name="documento" placeholder="12345678" required maxlength="20">
        </div>
        <div>
          <label>Teléfono</label>
          <input type="text" name="telefono" placeholder="987654321" maxlength="15">
        </div>
      </div>

      <label>Correo electrónico</label>
      <input type="email" name="email" placeholder="cliente@email.com" maxlength="100">

      <div class="modal-buttons">
        <button type="submit" class="btn-save"><i class="fa-solid fa-check"></i> Guardar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModalCliente()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- MODAL: EDITAR CLIENTE -->
<div class="modal-overlay" id="modalEditarCliente">
  <div class="modal" style="width:480px;">
    <form method="POST" action="ServletEditarCliente">
      <h2><i class="fa-solid fa-user-pen" style="color:#007bff;"></i> Editar Cliente</h2>
      <input type="hidden" name="id" id="editClienteId">

      <label>Nombre completo *</label>
      <input type="text" name="nombre" id="editClienteNombre" required maxlength="150">

      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
        <div>
          <label>DNI / Documento</label>
          <input type="text" name="documento" id="editClienteDoc" maxlength="20">
        </div>
        <div>
          <label>Teléfono</label>
          <input type="text" name="telefono" id="editClienteTel" maxlength="15">
        </div>
      </div>

      <label>Correo electrónico</label>
      <input type="email" name="email" id="editClienteEmail" maxlength="100">

      <div class="modal-buttons">
        <button type="submit" class="btn-save"><i class="fa-solid fa-check"></i> Actualizar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModalEditarCliente()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- FORM OCULTO: ELIMINAR -->
<form id="formEliminarCliente" method="POST" action="ServletEliminarCliente" style="display:none;">
  <input type="hidden" name="id" id="eliminarClienteId">
</form>

<script>
function abrirModalCliente()       { document.getElementById("modalCliente").style.display = "flex"; }
function cerrarModalCliente()      { document.getElementById("modalCliente").style.display = "none"; }
function cerrarModalEditarCliente(){ document.getElementById("modalEditarCliente").style.display = "none"; }

document.getElementById("modalCliente").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalCliente();
});
document.getElementById("modalEditarCliente").addEventListener("click", function(e) {
  if (e.target === this) cerrarModalEditarCliente();
});

function abrirModalEditarCliente(id, nombre, email, telefono, documento) {
  document.getElementById("editClienteId").value       = id;
  document.getElementById("editClienteNombre").value   = nombre;
  document.getElementById("editClienteEmail").value    = email !== "null" ? email : "";
  document.getElementById("editClienteTel").value      = telefono !== "null" ? telefono : "";
  document.getElementById("editClienteDoc").value      = documento !== "null" ? documento : "";
  document.getElementById("modalEditarCliente").style.display = "flex";
}

function confirmarEliminarCliente(id, nombre) {
  if (confirm("¿Eliminar al cliente " + nombre + "?\nEsta acción no se puede deshacer.")) {
    document.getElementById("eliminarClienteId").value = id;
    document.getElementById("formEliminarCliente").submit();
  }
}

function filtrarClientes() {
  const q = document.getElementById("searchCliente").value.toLowerCase();
  const cards = document.querySelectorAll("#clientesGrid .user-card");
  let visibles = 0;
  cards.forEach(card => {
    const match = card.dataset.nombre.includes(q)
                || card.dataset.email.includes(q)
                || card.dataset.doc.includes(q);
    card.style.display = match ? "" : "none";
    if (match) visibles++;
  });
  document.getElementById("sinClientes").style.display = visibles === 0 ? "block" : "none";
}
</script>
