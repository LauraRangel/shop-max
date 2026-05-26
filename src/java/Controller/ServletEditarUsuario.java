package Controller;

import Model.ModelUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/EditarUsuario")
public class ServletEditarUsuario extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int    id      = Integer.parseInt(request.getParameter("id"));
            String nombre  = request.getParameter("nombre");
            String email   = request.getParameter("email");
            int    idRol   = Integer.parseInt(request.getParameter("rol"));
            int    idTienda = Integer.parseInt(request.getParameter("tienda"));
            int    activo  = request.getParameter("activo") != null ? 1 : 0;

            new ModelUsuario().editarUsuario(id, nombre, email, idRol, idTienda, activo);

        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=usuarios");
    }
}
