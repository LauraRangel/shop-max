/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controller;

/**
 *
 * @author laurarangel
 */

import Entity.Usuario;
import Model.ModelUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

// mantiene el mismo nombre que el original para no romper el form del dashboard
@WebServlet(name = "ServletMantenimientoUsuario", urlPatterns = {"/ServletMantenimientoUsuario"})
public class ServletMantenimientoUsuario extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            System.out.println("REGISTRO USUARIO");

            int    idRol     = Integer.parseInt(request.getParameter("rol"));
            int    idTienda  = Integer.parseInt(request.getParameter("tienda"));
            String nombre    = request.getParameter("nombre");
            String email     = request.getParameter("email");
            String contrasena = request.getParameter("contrasena");

            Usuario u = new Usuario();
            u.setId_rol(idRol);
            u.setId_tienda(idTienda);
            u.setNombre(nombre);
            u.setEmail(email);
            u.setContrasena(contrasena);
            u.setActivo(1);

            ModelUsuario model = new ModelUsuario();
            boolean ok = model.saveUsuario(u);

            System.out.println("RESULTADO INSERT USER: " + ok);

            response.sendRedirect("dashboard");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }
}
