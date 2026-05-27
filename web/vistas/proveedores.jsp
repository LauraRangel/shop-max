<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>

<%
  ArrayList<HashMap<String,String>> proveedores =
      (ArrayList<HashMap<String,String>>) request.getAttribute("proveedores");

  int total = proveedores != null ? proveedores.size() : 0;
  // Menú ya restringe a Admin/Gerente — aquí igual como defensa interna
  boolean puedeGestionarProv = esAdmin || esGerente;
%>

<% if (!puedeGestionarProv) { %>
<div style="text-align:center;padding:60px;color:#aaa">
  <i class="fa-solid fa-lock" style="font-size:3rem;margin-bottom:12px"></i>
  <p>No tienes permiso para acceder a este módulo.</p>
</div>
<% return; } %>

<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-truck"></i> Gestión de Proveedores
  </h2>
  <button class="btn-add-user" onclick="abrirModal()">
    <i class="fa-solid fa-plus"></i> Agregar Proveedor
  </button>
</div>

<div class="users-stats">
  <div class="stat-card total">
    <p>Total de Proveedores</p>
    <h3><%= total %></h3>
  </div>
</div>

<div class="users-filters">
  <div class="search-box">
    <i class="fa fa-search"></i>
    <input type="text" id="searchSupplier" placeholder="Buscar por razón social o RUC..." oninput="filtrarProveedores()">
  </div>
</div>

<div class="users-grid" id="usersGrid">
  <% if (proveedores != null) {
       for (HashMap<String,String> u : proveedores) {
         String letra = u.get("razon_social") != null && !u.get("razon_social").isEmpty()
                        ? String.valueOf(u.get("razon_social").charAt(0)).toUpperCase() : "?";
  %>
  <div class="user-card"
       data-razonsocial="<%= u.get("razon_social").toLowerCase() %>"
       data-ruc="<%= u.get("ruc") %>">

    <div class="user-top">
      <div class="avatar"><%= letra %></div>
      <div class="user-info">
        <strong><%= u.get("razon_social") %></strong>
      </div>
    </div>

    <div class="user-info" style="margin-top:8px">
      <p><i class="fa-solid fa-file-invoice"></i> RUC: <%= u.get("ruc") %></p>
      <p><i class="fa-solid fa-user-tie"></i> <%= u.get("contacto") %></p>
      <p><i class="fa-solid fa-phone"></i> <%= u.get("telefono") %></p>
      <p><i class="fa-solid fa-envelope"></i> <%= u.get("email") %></p>
    </div>

    <div style="display:flex;gap:8px;margin-top:12px;justify-content:flex-end">
      <button onclick="abrirModalEditar('<%= u.get("id") %>','<%= u.get("razon_social") %>','<%= u.get("ruc") %>','<%= u.get("contacto") %>','<%= u.get("telefono") %>','<%= u.get("email") %>')"
              style="background:none;border:1px solid #007bff;color:#007bff;
                     padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
        <i class="fa-solid fa-pen"></i> Editar
      </button>

      <form method="POST" action="EliminarProveedor" style="display:inline"
            onsubmit="return confirm('¿Eliminar a <%= u.get("razon_social") %>?')">
        <input type="hidden" name="id" value="<%= u.get("id") %>">
        <button type="submit"
                style="background:none;border:1px solid #E24B4A;color:#E24B4A;
                       padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
          <i class="fa-solid fa-trash"></i> Eliminar
        </button>
      </form>
    </div>
  </div>
  <% } } %>
</div>

<div id="sinResultados" style="display:none;text-align:center;color:#aaa;padding:40px">
  <i class="fa-solid fa-magnifying-glass" style="font-size:2rem;margin-bottom:8px"></i>
  <p>No se encontraron proveedores</p>
</div>

<!-- Modal: Agregar Proveedor -->
<div class="modal-overlay" id="supplierModal">
  <div class="modal">
    <form method="POST" action="ServletMantenimientoProveedor" onsubmit="return validarFormProveedor('supplierModal')">
      <h2>Agregar Proveedor</h2>

      <label>Razón Social</label>
      <input type="text" name="razon_social" placeholder="Razón social de la empresa" required>

      <label>RUC <small style="color:#aaa">(11 dígitos)</small></label>
      <input type="text" name="ruc" id="rucAdd"
             placeholder="20123456789"
             maxlength="11" pattern="[0-9]{11}"
             title="El RUC debe tener exactamente 11 dígitos" required>

      <label>Contacto</label>
      <input type="text" name="contacto" placeholder="Nombre del contacto" required>

      <label>Teléfono <small style="color:#aaa">(9 dígitos)</small></label>
      <input type="text" name="telefono" id="telefonoAddP"
             placeholder="999999999"
             maxlength="9" pattern="[0-9]{9}"
             title="El teléfono debe tener exactamente 9 dígitos" required>

      <label>Email</label>
      <input type="email" name="email" placeholder="contacto@empresa.com" required>

      <div class="modal-buttons">
        <button type="submit" class="btn-save">Agregar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModal()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal: Editar Proveedor -->
<div class="modal-overlay" id="editModal">
  <div class="modal">
    <form method="POST" action="EditarProveedor" onsubmit="return validarFormProveedor('editModal')">
      <h2>Editar Proveedor</h2>
      <input type="hidden" name="id" id="editId">

      <label>Razón Social</label>
      <input type="text" name="razon_social" id="editRazonSocial" required>

      <label>RUC <small style="color:#aaa">(11 dígitos)</small></label>
      <input type="text" name="ruc" id="editRuc"
             maxlength="11" pattern="[0-9]{11}"
             title="El RUC debe tener exactamente 11 dígitos" required>

      <label>Contacto</label>
      <input type="text" name="contacto" id="editContacto" required>

      <label>Teléfono <small style="color:#aaa">(9 dígitos)</small></label>
      <input type="text" name="telefono" id="editTelefono"
             maxlength="9" pattern="[0-9]{9}"
             title="El teléfono debe tener exactamente 9 dígitos" required>

      <label>Email</label>
      <input type="email" name="email" id="editEmail" required>

      <div class="modal-buttons">
        <button type="submit" class="btn-save">Guardar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModalEditar()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<script>
  function abrirModal() {
    document.getElementById("supplierModal").style.display = "flex";
  }
  function cerrarModal() {
    document.getElementById("supplierModal").style.display = "none";
  }
  document.getElementById("supplierModal").addEventListener("click", function(e) {
    if (e.target === this) cerrarModal();
  });

  function abrirModalEditar(id, razon_social, ruc, contacto, telefono, email) {
    document.getElementById("editId").value           = id;
    document.getElementById("editRazonSocial").value  = razon_social;
    document.getElementById("editRuc").value          = ruc;
    document.getElementById("editContacto").value     = contacto;
    document.getElementById("editTelefono").value     = telefono;
    document.getElementById("editEmail").value        = email;
    document.getElementById("editModal").style.display = "flex";
  }
  function cerrarModalEditar() {
    document.getElementById("editModal").style.display = "none";
  }
  document.getElementById("editModal").addEventListener("click", function(e) {
    if (e.target === this) cerrarModalEditar();
  });

  function validarFormProveedor(modalId) {
    var modal = document.getElementById(modalId);
    var ruc   = modal.querySelector("[name='ruc']");
    var tel   = modal.querySelector("[name='telefono']");
    if (!/^[0-9]{11}$/.test(ruc.value)) {
      alert("El RUC debe tener exactamente 11 dígitos numéricos.");
      ruc.focus(); return false;
    }
    if (!/^[0-9]{9}$/.test(tel.value)) {
      alert("El teléfono debe tener exactamente 9 dígitos numéricos.");
      tel.focus(); return false;
    }
    return true;
  }

  // Solo permitir números en campos RUC y teléfono
  document.querySelectorAll("[name='ruc'],[name='telefono']").forEach(function(inp) {
    inp.addEventListener("input", function() {
      this.value = this.value.replace(/[^0-9]/g, "");
    });
  });

  function filtrarProveedores() {
    var texto    = document.getElementById("searchSupplier").value.toLowerCase().trim();
    var cards    = document.querySelectorAll("#usersGrid .user-card");
    var visibles = 0;
    cards.forEach(function(card) {
      var razonSocial = card.dataset.razonsocial || "";
      var ruc         = card.dataset.ruc         || "";
      var match       = razonSocial.includes(texto) || ruc.includes(texto);
      card.style.display = match ? "block" : "none";
      if (match) visibles++;
    });
    document.getElementById("sinResultados").style.display = visibles === 0 ? "block" : "none";
  }
</script>
