package Controller;

import Model.ModelInventario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/inventario")
public class ServletInventario extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("nombre") == null) {
            response.sendRedirect("login");
            return;
        }

        ModelInventario model = new ModelInventario();
        request.setAttribute("listaProductos", model.listarInventario());

        request.getRequestDispatcher("dashboard").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String accion = request.getParameter("accion");

            if ("entrada".equals(accion)) {
                int idProducto = Integer.parseInt(request.getParameter("idProducto"));
                int cantidad   = Integer.parseInt(request.getParameter("cantidad"));
                HttpSession session = request.getSession(false);
                int idTienda = session != null && session.getAttribute("id_tienda") != null
                             ? (int) session.getAttribute("id_tienda") : 1;

                new ModelInventario().registrarEntrada(idProducto, cantidad, idTienda);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=inventario");
    }
}
