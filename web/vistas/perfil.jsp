<%@page pageEncoding="UTF-8"%>

<div class="users-header">
  <h2 class="gradient-text">
    <i class="fa-solid fa-gear"></i> Configuración de cuenta
  </h2>
</div>

<%
  String ok           = (String) request.getAttribute("okPerfil");
  String error        = (String) request.getAttribute("errorPerfil");
  String okRec        = (String) session.getAttribute("okRecuperar");
  String errRec       = (String) session.getAttribute("errorRecuperar");
  if (okRec  != null) session.removeAttribute("okRecuperar");
  if (errRec != null) session.removeAttribute("errorRecuperar");
  boolean mostrarRec  = okRec != null || errRec != null;
%>

<div style="max-width:480px">

  <!-- INFO USUARIO -->
  <div style="background:#fff;border-radius:15px;padding:25px;
              box-shadow:0 10px 20px rgba(0,0,0,0.05);margin-bottom:25px;
              display:flex;align-items:center;gap:18px">
    <div class="avatar" style="width:56px;height:56px;font-size:22px">
      <%= session.getAttribute("nombre").toString().charAt(0) %>
    </div>
    <div>
      <strong style="font-size:16px"><%= session.getAttribute("nombre") %></strong>
      <p style="color:#888;font-size:13px;margin:3px 0"><%= session.getAttribute("rol") %></p>
    </div>
  </div>

  <!-- CAMBIAR CONTRASEÑA -->
  <div style="background:#fff;border-radius:15px;padding:25px;
              box-shadow:0 10px 20px rgba(0,0,0,0.05)">

    <!-- PANEL: cambiar con contraseña actual -->
    <div id="panelCambiar" style="<%= mostrarRec ? "display:none" : "" %>">
      <h3 style="margin-bottom:20px;color:#333">
        <i class="fa-solid fa-lock" style="color:#007bff"></i> Cambiar contraseña
      </h3>

      <% if (ok != null) { %>
        <div style="background:#E1F5EE;color:#0F6E56;padding:12px;border-radius:10px;
                    font-size:13px;margin-bottom:15px">
          <i class="fa-solid fa-circle-check"></i> <%= ok %>
        </div>
      <% } %>
      <% if (error != null) { %>
        <div style="background:#fde8e8;color:#E24B4A;padding:12px;border-radius:10px;
                    font-size:13px;margin-bottom:15px">
          <i class="fa-solid fa-circle-exclamation"></i> <%= error %>
        </div>
      <% } %>

      <form method="POST" action="CambiarPassword">
        <label style="font-size:13px;font-weight:600;display:block;margin-bottom:5px;color:#444">
          Contraseña actual
        </label>
        <input type="password" name="actual" required
               style="width:100%;padding:11px;border:2px solid #eee;border-radius:10px;
                      font-size:14px;outline:none;box-sizing:border-box;margin-bottom:15px;transition:0.2s"
               onfocus="this.style.borderColor='#007bff'" onblur="this.style.borderColor='#eee'">

        <label style="font-size:13px;font-weight:600;display:block;margin-bottom:5px;color:#444">
          Nueva contraseña
        </label>
        <input type="password" name="nueva" required minlength="4"
               style="width:100%;padding:11px;border:2px solid #eee;border-radius:10px;
                      font-size:14px;outline:none;box-sizing:border-box;margin-bottom:15px;transition:0.2s"
               onfocus="this.style.borderColor='#007bff'" onblur="this.style.borderColor='#eee'">

        <label style="font-size:13px;font-weight:600;display:block;margin-bottom:5px;color:#444">
          Confirmar nueva contraseña
        </label>
        <input type="password" name="confirmar" required minlength="4"
               style="width:100%;padding:11px;border:2px solid #eee;border-radius:10px;
                      font-size:14px;outline:none;box-sizing:border-box;margin-bottom:20px;transition:0.2s"
               onfocus="this.style.borderColor='#007bff'" onblur="this.style.borderColor='#eee'">

        <button type="submit" class="btn-add-user" style="width:100%;justify-content:center">
          <i class="fa-solid fa-floppy-disk"></i> Guardar contraseña
        </button>
      </form>

      <button onclick="mostrarPanelPerfil('recuperar')"
              style="background:none;border:none;width:100%;margin-top:14px;
                     font-size:13px;color:#7b2ff7;font-weight:600;cursor:pointer;text-align:center;">
        ¿No recuerdas tu contraseña actual?
      </button>
    </div>

    <!-- PANEL: recuperar por correo -->
    <div id="panelRecuperar" style="<%= mostrarRec ? "" : "display:none" %>">
      <h3 style="margin-bottom:8px;color:#333">
        <i class="fa-solid fa-envelope" style="color:#007bff"></i> Recuperar contraseña
      </h3>
      <p style="font-size:13px;color:#888;margin-bottom:20px">
        Te enviaremos instrucciones a tu correo registrado.
      </p>

      <% if (okRec != null) { %>
        <div style="background:#E1F5EE;color:#0F6E56;padding:12px;border-radius:10px;
                    font-size:13px;margin-bottom:15px">
          <i class="fa-solid fa-circle-check"></i> <%= okRec %>
        </div>
      <% } else if (errRec != null) { %>
        <div style="background:#fde8e8;color:#E24B4A;padding:12px;border-radius:10px;
                    font-size:13px;margin-bottom:15px">
          <i class="fa-solid fa-circle-exclamation"></i> <%= errRec %>
        </div>
      <% } %>

      <% if (okRec == null) { %>
      <form method="POST" action="recuperar">
        <input type="hidden" name="from" value="perfil">
        <label style="font-size:13px;font-weight:600;display:block;margin-bottom:5px;color:#444">
          Correo Electrónico
        </label>
        <input type="email" name="email" placeholder="correo@ejemplo.com" required
               style="width:100%;padding:11px;border:2px solid #eee;border-radius:10px;
                      font-size:14px;outline:none;box-sizing:border-box;margin-bottom:20px;transition:0.2s"
               onfocus="this.style.borderColor='#007bff'" onblur="this.style.borderColor='#eee'">
        <button type="submit" class="btn-add-user" style="width:100%;justify-content:center">
          <i class="fa-solid fa-paper-plane"></i> Enviar instrucciones
        </button>
      </form>
      <% } %>

      <button onclick="mostrarPanelPerfil('cambiar')"
              style="background:none;border:none;width:100%;margin-top:14px;
                     font-size:13px;color:#7b2ff7;font-weight:600;cursor:pointer;text-align:center;">
        <i class="fa-solid fa-arrow-left"></i> Volver
      </button>
    </div>

  </div>
</div>

<script>
  function mostrarPanelPerfil(panel) {
    document.getElementById("panelCambiar").style.display   = panel === "cambiar"   ? "block" : "none";
    document.getElementById("panelRecuperar").style.display = panel === "recuperar" ? "block" : "none";
  }
</script>
