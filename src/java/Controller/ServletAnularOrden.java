package Controller;

import Model.ModelCompra;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/ServletAnularOrden")
public class ServletAnularOrden extends HttpServlet {

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
            response.sendRedirect("dashboard?mod=compras");
            return;
        }

        try {
            int idOrden  = Integer.parseInt(request.getParameter("idOrden"));
            int idTienda = (int) session.getAttribute("id_tienda");

            new ModelCompra().anularOrden(idOrden, idTienda);
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("dashboard?mod=compras");
    }
}
