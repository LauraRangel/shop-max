/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controller;

/**
 *
 * @author laurarangel
 */

import Model.ModelHome;
import Model.ModelRol;
import Model.ModelTienda;
import Model.ModelUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/dashboard")
public class ServletDashboard extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // verificar sesión activa
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("nombre") == null) {
            response.sendRedirect("login");
            return;
        }

        // cargar datos comunes para todos los módulos
        request.setAttribute("roles",    new ModelRol().listarRoles());
        request.setAttribute("tiendas",  new ModelTienda().listarTiendas());
        request.setAttribute("usuarios", new ModelUsuario().listarUsuarios());
        request.setAttribute("resumen",  new ModelHome().getResumen());

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}
