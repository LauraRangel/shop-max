<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.time.LocalDate"%>

<%
  ArrayList<HashMap<String,String>> clientes =
      (ArrayList<HashMap<String,String>>) request.getAttribute("clientes");

  int total = clientes != null ? clientes.size() : 0;
  boolean puedeGestionar = esAdmin || esGerente;
%>

<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-users"></i> Gestión de Clientes
  </h2>
  <% if (puedeGestionar) { %>
  <button class="btn-add-user" onclick="abrirModal()">
    <i class="fa-solid fa-plus"></i> Agregar Cliente
  </button>
  <% } %>
</div>

<div class="users-stats">
  <div class="stat-card total">
    <p>Total de Clientes</p>
    <h3><%= total %></h3>
  </div>
</div>

<div class="users-filters">
  <div class="search-box">
    <i class="fa fa-search"></i>
    <input type="text" id="searchCustomer" placeholder="Buscar por nombre o documento..." oninput="filtrarClientes()">
  </div>
</div>

<div class="users-grid" id="usersGrid">
  <% if (clientes != null) {
       for (HashMap<String,String> u : clientes) {
         String letra = u.get("nombre") != null && !u.get("nombre").isEmpty()
                        ? String.valueOf(u.get("nombre").charAt(0)).toUpperCase() : "?";
  %>
  <div class="user-card"
       data-nombre="<%= u.get("nombre").toLowerCase() %>"
       data-documento="<%= u.get("documento") %>">

    <div class="user-top">
      <div class="avatar"><%= letra %></div>
      <div class="user-info">
        <strong><%= u.get("nombre") %></strong>
      </div>
    </div>

    <div class="user-info" style="margin-top:8px">
      <p><i class="fa-solid fa-envelope"></i> <%= u.get("email") %></p>
      <p><i class="fa-solid fa-phone"></i> <%= u.get("telefono") %></p>
      <p><i class="fa-solid fa-address-card"></i> DNI: <%= u.get("documento") %></p>
      <p><i class="fa-solid fa-calendar-days"></i> <%= u.get("fecha_registro") %></p>
    </div>

    <% if (puedeGestionar) { %>
    <div style="display:flex;gap:8px;margin-top:12px;justify-content:flex-end">
      <button onclick="abrirModalEditar('<%= u.get("id") %>','<%= u.get("nombre") %>','<%= u.get("email") %>','<%= u.get("telefono") %>','<%= u.get("documento") %>')"
              style="background:none;border:1px solid #007bff;color:#007bff;
                     padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
        <i class="fa-solid fa-pen"></i> Editar
      </button>

      <form method="POST" action="EliminarCliente" style="display:inline"
            onsubmit="return confirm('¿Eliminar a <%= u.get("nombre") %>?')">
        <input type="hidden" name="id" value="<%= u.get("id") %>">
        <button type="submit"
                style="background:none;border:1px solid #E24B4A;color:#E24B4A;
                       padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
          <i class="fa-solid fa-trash"></i> Eliminar
        </button>
      </form>
    </div>
    <% } %>
  </div>
  <% } } %>
</div>

<div id="sinResultados" style="display:none;text-align:center;color:#aaa;padding:40px">
  <i class="fa-solid fa-magnifying-glass" style="font-size:2rem;margin-bottom:8px"></i>
  <p>No se encontraron clientes</p>
</div>

<% if (puedeGestionar) { %>
<!-- Modal: Agregar Cliente -->
<div class="modal-overlay" id="customerModal">
  <div class="modal">
    <form method="POST" action="ServletMantenimientoCliente" onsubmit="return validarFormCliente('customerModal')">
      <h2>Agregar Cliente</h2>

      <label>Nombre</label>
      <input type="text" name="nombre" placeholder="Ingrese nombre completo" required>

      <label>Email</label>
      <input type="email" name="email" placeholder="ejemplo@correo.com" required>

      <label>Teléfono <small style="color:#aaa">(9 dígitos)</small></label>
      <input type="text" name="telefono" id="telefonoAdd"
             placeholder="999999999"
             maxlength="9" pattern="[0-9]{9}"
             title="El teléfono debe tener exactamente 9 dígitos" required>

      <label>DNI <small style="color:#aaa">(8 dígitos)</small></label>
      <input type="text" name="documento" id="documentoAdd"
             placeholder="12345678"
             maxlength="8" pattern="[0-9]{8}"
             title="El DNI debe tener exactamente 8 dígitos" required>

      <input type="hidden" name="fecha_registro" value="<%= LocalDate.now() %>">

      <div class="modal-buttons">
        <button type="submit" class="btn-save">Agregar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModal()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal: Editar Cliente -->
<div class="modal-overlay" id="editModal">
  <div class="modal">
    <form method="POST" action="EditarCliente" onsubmit="return validarFormCliente('editModal')">
      <h2>Editar Cliente</h2>
      <input type="hidden" name="id" id="editId">

      <label>Nombre</label>
      <input type="text" name="nombre" id="editNombre" required>

      <label>Email</label>
      <input type="email" name="email" id="editEmail" required>

      <label>Teléfono <small style="color:#aaa">(9 dígitos)</small></label>
      <input type="text" name="telefono" id="editTelefono"
             maxlength="9" pattern="[0-9]{9}"
             title="El teléfono debe tener exactamente 9 dígitos" required>

      <label>DNI <small style="color:#aaa">(8 dígitos)</small></label>
      <input type="text" name="documento" id="editDocumento"
             maxlength="8" pattern="[0-9]{8}"
             title="El DNI debe tener exactamente 8 dígitos" required>

      <div class="modal-buttons">
        <button type="submit" class="btn-save">Guardar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModalEditar()">Cancelar</button>
      </div>
    </form>
  </div>
</div>
<% } %>

<script>
  <% if (puedeGestionar) { %>
  function abrirModal() {
    document.getElementById("customerModal").style.display = "flex";
  }
  function cerrarModal() {
    document.getElementById("customerModal").style.display = "none";
  }
  document.getElementById("customerModal").addEventListener("click", function(e) {
    if (e.target === this) cerrarModal();
  });

  function abrirModalEditar(id, nombre, email, telefono, documento) {
    document.getElementById("editId").value        = id;
    document.getElementById("editNombre").value    = nombre;
    document.getElementById("editEmail").value     = email;
    document.getElementById("editTelefono").value  = telefono;
    document.getElementById("editDocumento").value = documento;
    document.getElementById("editModal").style.display = "flex";
  }
  function cerrarModalEditar() {
    document.getElementById("editModal").style.display = "none";
  }
  document.getElementById("editModal").addEventListener("click", function(e) {
    if (e.target === this) cerrarModalEditar();
  });

  function validarFormCliente(modalId) {
    var modal    = document.getElementById(modalId);
    var tel      = modal.querySelector("[name='telefono']");
    var doc      = modal.querySelector("[name='documento']");
    if (!/^[0-9]{9}$/.test(tel.value)) {
      alert("El teléfono debe tener exactamente 9 dígitos numéricos.");
      tel.focus(); return false;
    }
    if (!/^[0-9]{8}$/.test(doc.value)) {
      alert("El DNI debe tener exactamente 8 dígitos numéricos.");
      doc.focus(); return false;
    }
    return true;
  }

  // Solo permitir números en campos DNI y teléfono
  document.querySelectorAll("[name='telefono'],[name='documento']").forEach(function(inp) {
    inp.addEventListener("input", function() {
      this.value = this.value.replace(/[^0-9]/g, "");
    });
  });
  <% } %>

  function filtrarClientes() {
    var texto    = document.getElementById("searchCustomer").value.toLowerCase().trim();
    var cards    = document.querySelectorAll("#usersGrid .user-card");
    var visibles = 0;
    cards.forEach(function(card) {
      var nombre    = card.dataset.nombre    || "";
      var documento = card.dataset.documento || "";
      var match     = nombre.includes(texto) || documento.includes(texto);
      card.style.display = match ? "block" : "none";
      if (match) visibles++;
    });
    document.getElementById("sinResultados").style.display = visibles === 0 ? "block" : "none";
  }
</script>
