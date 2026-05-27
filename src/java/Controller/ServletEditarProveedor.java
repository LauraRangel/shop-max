
package Controller;

import Model.ModelProveedor;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/EditarProveedor")
public class ServletEditarProveedor extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int    id      = Integer.parseInt(request.getParameter("id"));
            String razon_social  = request.getParameter("razon_social");
            String ruc   = request.getParameter("ruc");
            String contacto   = request.getParameter("contacto");
            String telefono   = request.getParameter("telefono");
            String email   = request.getParameter("email");

            new ModelProveedor().editarProveedor(id, razon_social, ruc, contacto, telefono, email);

        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=proveedores");
    }
}
