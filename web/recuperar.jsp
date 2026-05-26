<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>SHOP-MAX | Recuperar Contraseña</title>
  <link rel="stylesheet" href="css/system/styles.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    body {
      background: rgb(229,232,255);
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }
    .box {
      background: #fff;
      padding: 40px;
      border-radius: 20px;
      width: 420px;
      box-shadow: 0 15px 40px rgba(0,0,0,0.1);
    }
    .box-logo { text-align: center; margin-bottom: 20px; }
    .box-logo img { width: 80px; }
    .box h2 {
      background: linear-gradient(90deg, #007bff, #7b2ff7);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      font-size: 24px;
      margin-bottom: 8px;
      text-align: center;
    }
    .box p.sub {
      text-align: center;
      font-size: 13px;
      color: #888;
      margin-bottom: 25px;
    }
    .box label {
      font-size: 13px;
      font-weight: 600;
      display: block;
      margin-bottom: 5px;
      color: #444;
    }
    .input-group {
      position: relative;
      margin-bottom: 15px;
    }
    .input-group i {
      position: absolute;
      left: 13px;
      top: 50%;
      transform: translateY(-50%);
      color: #007bff;
    }
    .input-group input {
      width: 100%;
      padding: 12px 12px 12px 38px;
      border: 2px solid #eee;
      border-radius: 10px;
      font-size: 14px;
      outline: none;
      box-sizing: border-box;
      transition: 0.2s;
    }
    .input-group input:focus { border-color: #007bff; }
    .btn-primary {
      width: 100%;
      padding: 13px;
      background: linear-gradient(90deg, #007bff, #7b2ff7);
      color: #fff;
      border: none;
      border-radius: 30px;
      font-size: 15px;
      font-weight: 600;
      cursor: pointer;
      transition: 0.3s;
      margin-top: 5px;
    }
    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 15px rgba(0,0,0,0.2);
    }
    .msg-ok {
      background: #E1F5EE;
      color: #0F6E56;
      padding: 12px;
      border-radius: 10px;
      font-size: 13px;
      text-align: center;
      margin-bottom: 15px;
    }
    .msg-error {
      background: #fde8e8;
      color: #E24B4A;
      padding: 12px;
      border-radius: 10px;
      font-size: 13px;
      text-align: center;
      margin-bottom: 15px;
    }
    .volver {
      display: block;
      text-align: center;
      margin-top: 18px;
      font-size: 13px;
      color: #7b2ff7;
      font-weight: 600;
      text-decoration: none;
    }
    .volver:hover { text-decoration: underline; }
  </style>
</head>
<body>
<div class="box">
  <div class="box-logo">
    <img src="images/logo/logo.png" alt="SHOP-MAX">
  </div>
  <h2>Recuperar Contraseña</h2>
  <p class="sub">Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.</p>

  <%
    String ok    = (String) request.getAttribute("ok");
    String error = (String) request.getAttribute("error");
    if (ok != null) {
  %>
    <div class="msg-ok">
      <i class="fa-solid fa-circle-check"></i> <%= ok %>
    </div>
  <% } else if (error != null) { %>
    <div class="msg-error">
      <i class="fa-solid fa-circle-exclamation"></i> <%= error %>
    </div>
  <% } %>

  <% if (ok == null) { %>
  <form method="POST" action="recuperar">
    <label>Correo Electrónico</label>
    <div class="input-group">
      <i class="fa-solid fa-envelope"></i>
      <input type="email" name="email" placeholder="correo@ejemplo.com" required>
    </div>
    <button type="submit" class="btn-primary">
      <i class="fa-solid fa-paper-plane"></i> Enviar enlace
    </button>
  </form>
  <% } %>

  <a href="login" class="volver">
    <i class="fa-solid fa-arrow-left"></i> Volver al inicio de sesión
  </a>
</div>
</body>
</html>
