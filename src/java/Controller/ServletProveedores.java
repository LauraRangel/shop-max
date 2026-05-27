package Controller;

import Entity.Proveedor;
import Model.ModelProveedor;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/proveedores")
public class ServletProveedores extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("nombre") == null) {
            response.sendRedirect("login");
            return;
        }

        ModelProveedor model = new ModelProveedor();
        request.setAttribute("listaProveedores", model.listarProveedores());

        request.getRequestDispatcher("dashboard").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Proveedor p = new Proveedor();
            p.setRazon_social(request.getParameter("razonSocial"));
            p.setRuc(request.getParameter("ruc"));
            p.setContacto(request.getParameter("contacto"));
            p.setTelefono(request.getParameter("telefono"));
            p.setEmail(request.getParameter("email"));
            new ModelProveedor().saveProveedor(p);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=proveedores");
    }
}
