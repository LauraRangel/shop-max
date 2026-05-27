package Controller;

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
            String razonSocial = request.getParameter("razonSocial");
            String ruc         = request.getParameter("ruc");
            String contacto    = request.getParameter("contacto");
            String telefono    = request.getParameter("telefono");
            String email       = request.getParameter("email");
            new ModelProveedor().saveProveedor(razonSocial, ruc, contacto, telefono, email);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=proveedores");
    }
}
