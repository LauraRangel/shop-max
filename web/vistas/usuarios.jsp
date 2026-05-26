<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>

<%
  ArrayList<HashMap<String,String>> usuarios =
      (ArrayList<HashMap<String,String>>) request.getAttribute("usuarios");
  ArrayList<HashMap<String,String>> roles =
      (ArrayList<HashMap<String,String>>) request.getAttribute("roles");
  ArrayList<HashMap<String,String>> tiendas =
      (ArrayList<HashMap<String,String>>) request.getAttribute("tiendas");

  int total   = usuarios != null ? usuarios.size() : 0;
  int activos = 0;
  if (usuarios != null)
    for (HashMap<String,String> u : usuarios)
      if ("1".equals(u.get("activo"))) activos++;
%>

<!-- HEADER -->
<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-user-gear"></i> Gestión de Usuarios
  </h2>
  <button class="btn-add-user" onclick="abrirModal()">
    <i class="fa-solid fa-plus"></i> Agregar Usuario
  </button>
</div>

<!-- STATS -->
<div class="users-stats">
  <div class="stat-card total">
    <p>Total de Usuarios</p>
    <h3><%= total %></h3>
  </div>
  <div class="stat-card active">
    <p>Usuarios Activos</p>
    <h3><%= activos %></h3>
  </div>
  <div class="stat-card inactive">
    <p>Usuarios Inactivos</p>
    <h3><%= total - activos %></h3>
  </div>
</div>

<!-- FILTROS -->
<div class="users-filters">
  <div class="search-box">
    <i class="fa fa-search"></i>
    <input type="text" id="searchUser" placeholder="Buscar usuarios..." oninput="filtrarUsuarios()">
  </div>
  <select id="roleFilter" onchange="filtrarUsuarios()">
    <option value="">👤 Todos los roles</option>
    <% if (roles != null) for (HashMap<String,String> r : roles) { %>
      <option value="<%= r.get("nombre") %>"><%= r.get("nombre") %></option>
    <% } %>
  </select>
  <select id="statusFilter" onchange="filtrarUsuarios()">
    <option value="">🔘 Todos</option>
    <option value="1" selected>✅ Activos</option>
    <option value="0">❌ Inactivos</option>
  </select>
</div>

<!-- GRID DE TARJETAS -->
<div class="users-grid" id="usersGrid">
  <% if (usuarios != null) {
       for (HashMap<String,String> u : usuarios) {
         String estadoColor = "1".equals(u.get("activo")) ? "#E1F5EE" : "#fde8e8";
         String estadoTexto = "1".equals(u.get("activo")) ? "Activo"  : "Inactivo";
         String estadoFont  = "1".equals(u.get("activo")) ? "#0F6E56" : "#E24B4A";
         String letra       = u.get("nombre") != null && !u.get("nombre").isEmpty()
                              ? String.valueOf(u.get("nombre").charAt(0)).toUpperCase() : "?";
  %>
  <div class="user-card"
       data-nombre="<%= u.get("nombre").toLowerCase() %>"
       data-rol="<%= u.get("rol") %>"
       data-activo="<%= u.get("activo") %>">

    <div class="user-top">
      <div class="avatar"><%= letra %></div>
      <div class="user-info">
        <strong><%= u.get("nombre") %></strong>
        <small style="color:#888"><%= u.get("rol") %></small>
      </div>
      <span style="margin-left:auto;font-size:11px;padding:3px 10px;
            border-radius:20px;font-weight:600;
            background:<%= estadoColor %>;color:<%= estadoFont %>">
        <%= estadoTexto %>
      </span>
    </div>

    <div class="user-info" style="margin-top:8px">
      <p><i class="fa-solid fa-envelope"></i> <%= u.get("email") %></p>
      <p><i class="fa-solid fa-store"></i> <%= u.get("tienda") %></p>
    </div>

    <div style="display:flex;gap:8px;margin-top:12px;justify-content:flex-end">
      <button onclick="abrirModalEditar('<%= u.get("id") %>','<%= u.get("nombre") %>','<%= u.get("email") %>','<%= u.get("rol") %>','<%= u.get("tienda") %>','<%= u.get("activo") %>')"
              style="background:none;border:1px solid #007bff;color:#007bff;
                     padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
        <i class="fa-solid fa-pen"></i> Editar
      </button>
      <% if ("1".equals(u.get("activo"))) { %>
      <form method="POST" action="EliminarUsuario" style="display:inline"
            onsubmit="return confirm('¿Desactivar a <%= u.get("nombre") %>? El usuario no podrá iniciar sesión.')">
        <input type="hidden" name="id" value="<%= u.get("id") %>">
        <button type="submit"
                style="background:none;border:1px solid #E24B4A;color:#E24B4A;
                       padding:5px 12px;border-radius:20px;cursor:pointer;font-size:12px;">
          <i class="fa-solid fa-trash"></i> Eliminar
        </button>
      </form>
      <% } %>
    </div>
  </div>
  <% } } %>
</div>

<p id="sinResultados" style="display:none;text-align:center;color:#888;margin-top:30px;">
  No se encontraron usuarios.
</p>

<!-- MODAL AGREGAR USUARIO -->
<div class="modal-overlay" id="userModal">
  <div class="modal">
    <form method="POST" action="ServletMantenimientoUsuario">
      <h2>Agregar Usuario</h2>

      <label>Nombre de Usuario</label>
      <input type="text" name="nombre" placeholder="Ingrese nombre" required>

      <label>Tipo de Usuario</label>
      <select name="rol" required>
        <% if (roles != null) for (HashMap<String,String> r : roles) { %>
          <option value="<%= r.get("id") %>"><%= r.get("nombre") %></option>
        <% } %>
      </select>

      <label>Email</label>
      <input type="email" name="email" placeholder="Ingrese email" required>

      <label>Contraseña</label>
      <input type="password" name="contrasena" placeholder="Ingrese contraseña" required>

      <label>Tienda</label>
      <select name="tienda" required>
        <% if (tiendas != null) for (HashMap<String,String> t : tiendas) { %>
          <option value="<%= t.get("id") %>"><%= t.get("nombre") %></option>
        <% } %>
      </select>

      <div class="modal-buttons">
        <button type="submit" class="btn-save">Agregar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModal()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- MODAL EDITAR USUARIO -->
<div class="modal-overlay" id="editModal">
  <div class="modal">
    <form method="POST" action="EditarUsuario">
      <h2>Editar Usuario</h2>
      <input type="hidden" name="id" id="editId">

      <label>Nombre</label>
      <input type="text" name="nombre" id="editNombre" required>

      <label>Tipo de Usuario</label>
      <select name="rol" id="editRol" required>
        <% if (roles != null) for (HashMap<String,String> r : roles) { %>
          <option value="<%= r.get("id") %>"><%= r.get("nombre") %></option>
        <% } %>
      </select>

      <label>Email</label>
      <input type="email" name="email" id="editEmail" required>

      <label>Tienda</label>
      <select name="tienda" id="editTienda" required>
        <% if (tiendas != null) for (HashMap<String,String> t : tiendas) { %>
          <option value="<%= t.get("id") %>"><%= t.get("nombre") %></option>
        <% } %>
      </select>

      <label style="display:flex;align-items:center;gap:8px;margin-top:12px;cursor:pointer;">
        <input type="checkbox" name="activo" id="editActivo" style="width:auto;margin:0;">
        Usuario activo
      </label>

      <div class="modal-buttons">
        <button type="submit" class="btn-save">Guardar</button>
        <button type="button" class="btn-cancel" onclick="cerrarModalEditar()">Cancelar</button>
      </div>
    </form>
  </div>
</div>

<!-- JS INLINE — búsqueda, filtro y modal -->
<script>
  function abrirModal() {
    document.getElementById("userModal").style.display = "flex";
  }

  function cerrarModal() {
    document.getElementById("userModal").style.display = "none";
  }

  // cerrar modal al hacer clic fuera
  document.getElementById("userModal").addEventListener("click", function(e) {
    if (e.target === this) cerrarModal();
  });

  function abrirModalEditar(id, nombre, email, rol, tienda, activo) {
    document.getElementById("editId").value     = id;
    document.getElementById("editNombre").value = nombre;
    document.getElementById("editEmail").value  = email;
    document.getElementById("editActivo").checked = activo === "1";

    // seleccionar rol por nombre
    const selRol = document.getElementById("editRol");
    for (let i = 0; i < selRol.options.length; i++)
      if (selRol.options[i].text === rol) { selRol.selectedIndex = i; break; }

    // seleccionar tienda por nombre
    const selTienda = document.getElementById("editTienda");
    for (let i = 0; i < selTienda.options.length; i++)
      if (selTienda.options[i].text === tienda) { selTienda.selectedIndex = i; break; }

    document.getElementById("editModal").style.display = "flex";
  }

  function cerrarModalEditar() {
    document.getElementById("editModal").style.display = "none";
  }

  // aplicar filtro al cargar — muestra solo activos por default
  filtrarUsuarios();

  document.getElementById("editModal").addEventListener("click", function(e) {
    if (e.target === this) cerrarModalEditar();
  });

  function filtrarUsuarios() {
    const texto  = document.getElementById("searchUser").value.toLowerCase().trim();
    const rol    = document.getElementById("roleFilter").value.toLowerCase();
    const estado = document.getElementById("statusFilter").value;
    const cards  = document.querySelectorAll("#usersGrid .user-card");
    let visibles = 0;

    cards.forEach(function(card) {
      const nombre   = card.dataset.nombre  || "";
      const cardRol  = card.dataset.rol.toLowerCase() || "";
      const cardActivo = card.dataset.activo || "";

      const matchNombre = nombre.includes(texto);
      const matchRol    = rol    === "" || cardRol    === rol;
      const matchEstado = estado === "" || cardActivo === estado;

      if (matchNombre && matchRol && matchEstado) {
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
