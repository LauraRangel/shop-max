package Controller;

import Entity.Proveedor;
import Model.ModelProveedor;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/ServletGuardarProveedor")
public class ServletGuardarProveedor extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
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
