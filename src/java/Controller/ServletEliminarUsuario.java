package Controller;

import Model.ModelUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/EliminarUsuario")
public class ServletEliminarUsuario extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            new ModelUsuario().desactivarUsuario(id);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=usuarios");
    }
}
