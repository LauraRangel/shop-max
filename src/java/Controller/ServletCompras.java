package Controller;

import Model.ModelCompra;
import Model.ModelProveedor;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/compras")
public class ServletCompras extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("nombre") == null) {
            response.sendRedirect("login");
            return;
        }

        ModelCompra modelCompra = new ModelCompra();
        ModelProveedor modelProveedor = new ModelProveedor();

        request.setAttribute("listaOrdenes", modelCompra.listarOrdenes());
        request.setAttribute("listaProveedores", modelProveedor.listarProveedores());

        request.getRequestDispatcher("dashboard").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int idProveedor = Integer.parseInt(request.getParameter("idProveedor"));
            String total = request.getParameter("total");

            ModelCompra model = new ModelCompra();
            model.saveOrden(idProveedor, total);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=compras");
    }
}
