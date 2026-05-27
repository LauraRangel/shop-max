<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>

<%
  ArrayList<HashMap<String,String>> proveedores =
      (ArrayList<HashMap<String,String>>) request.getAttribute("proveedores");

  int total   = proveedores != null ? proveedores.size() : 0;
%>

<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-users"></i> Gestión de Proveedores
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
    <input type="text" id="searchSupplier" placeholder="Buscar proveedores..." oninput="filtrarProveedores()">
  </div>
</div>
  
<div class="users-grid" id="usersGrid">
  <% if (proveedores != null) {
       for (HashMap<String,String> u : proveedores) {
         String letra       = u.get("razon_social") != null && !u.get("razon_social").isEmpty()
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
      <p><i class="fa-solid fa-building"></i> <%= u.get("razon_social") %></p>
      <p><i class="fa-solid fa-file-invoice"></i> <%= u.get("ruc") %></p>
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

<div class="modal-overlay" id="supplierModal">
  <div class="modal">
    <form method="POST" action="ServletMantenimientoProveedor">
      <h2>Agregar Proveedor</h2>

      <label>Razón Social</label>
      <input type="text" name="razon_social" placeholder="Ingrese razón social" required>

      <label>Ruc</label>
      <input type="text" name="ruc" placeholder="Ingrese ruc" required>

      <label>Contacto</label>
      <input type="text" name="contacto" placeholder="Ingrese contacto" required>
      
      <label>Telefono</label>
      <input type="text" name="telefono" placeholder="Ingrese telefono" required>
      
      <label>Email</label>
      <input type="email" name="email" placeholder="Ingrese email" required>

      <div class="modal-buttons">
        <button type="submit" class="btn-save">Agregar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModal()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<div class="modal-overlay" id="editModal">
  <div class="modal">
    <form method="POST" action="EditarProveedor">
      <h2>Editar Proveedor</h2>
      <input type="hidden" name="id" id="editId">

      <label>Razón Social</label>
      <input type="text" name="razon_social" id="editRazonSocial" required>

      <label>Ruc</label>
      <input type="text" name="ruc" id="editRuc" required>
      
      <label>Contacto</label>
      <input type="text" name="contacto" id="editContacto" required>
      
      <label>Telefono</label>
      <input type="text" name="telefono" id="editTelefono" required>
      
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
        document.getElementById("editId").value     = id;
        document.getElementById("editRazonSocial").value = razon_social;
        document.getElementById("editRuc").value = ruc;
        document.getElementById("editContacto").value  = contacto;
        document.getElementById("editTelefono").value = telefono;
        document.getElementById("editEmail").value = email;   

        document.getElementById("editModal").style.display = "flex";
      }
      
      function cerrarModalEditar() {
        document.getElementById("editModal").style.display = "none";
      }
      
      document.getElementById("editModal").addEventListener("click", function(e) {
        if (e.target === this) cerrarModalEditar();
      });
      
      function filtrarProveedores() {
        const texto  = document.getElementById("searchSupplier").value.toLowerCase().trim();
        const cards  = document.querySelectorAll("#usersGrid .user-card");
        let visibles = 0;

        cards.forEach(function(card) {
          const razon_social   = card.dataset.razonsocial  || "";
          const ruc   = card.dataset.ruc  || "";

          const match = razon_social.includes(texto) || ruc.includes(texto);

          if (match) {
            card.style.display = "block";
            visibles++;
          } else {
            card.style.display = "none";
          }
        });

        document.getElementById("sinResultados").style.display =
          visibles === 0 ? "block" : "none";
      }
  </script>