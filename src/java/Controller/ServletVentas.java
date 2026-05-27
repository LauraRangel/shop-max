package Controller;

import Model.ModelVenta;
import Model.ModelProducto;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/ventas")
public class ServletVentas extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("nombre") == null) {
            response.sendRedirect("login");
            return;
        }

        ModelVenta modelVenta = new ModelVenta();
        ModelProducto modelProducto = new ModelProducto();

        request.setAttribute("listaVentas", modelVenta.listarVentas());
        request.setAttribute("listaProductos", modelProducto.listarProductos());

        request.getRequestDispatcher("dashboard").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String idCliente = request.getParameter("idCliente");
            String total = request.getParameter("total");
            String tipoPago = request.getParameter("tipoPago");

            HttpSession session = request.getSession();
            Integer idUsuario = (Integer) session.getAttribute("id_usuario");

            if (idUsuario != null) {
                ModelVenta model = new ModelVenta();
                model.saveVenta(idCliente, idUsuario.intValue(), total, tipoPago);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=ventas");
    }
}
