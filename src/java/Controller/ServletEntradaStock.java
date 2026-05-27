package Controller;

import Model.ModelInventario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/ServletEntradaStock")
public class ServletEntradaStock extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("id_usuario") == null) {
            response.sendRedirect("login");
            return;
        }
        String rol = (String) session.getAttribute("rol");
        if (!"Administrador".equals(rol) && !"Gerente de Tienda".equals(rol)) {
            response.sendRedirect("dashboard?mod=inventario");
            return;
        }

        try {
            int idProducto = Integer.parseInt(request.getParameter("idProducto"));
            int cantidad   = Integer.parseInt(request.getParameter("cantidad"));
            int idTienda   = (int) session.getAttribute("id_tienda");

            new ModelInventario().registrarEntrada(idProducto, cantidad, idTienda);
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("dashboard?mod=inventario");
    }
}
