
package Controller;

import Entity.Proveedor;
import Model.ModelProveedor;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "ServletMantenimientoProveedor", urlPatterns = {"/ServletMantenimientoProveedor"})
public class ServletMantenimientoProveedor extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            System.out.println("REGISTRO PROVEEDOR");

            String razon_social    = request.getParameter("razon_social");
            String ruc     = request.getParameter("ruc");
            String contacto = request.getParameter("contacto");
            String telefono = request.getParameter("telefono");
            String email = request.getParameter("email");

            Proveedor u = new Proveedor();
            u.setRazon_social(razon_social);
            u.setRuc(ruc);
            u.setContacto(contacto);
            u.setTelefono(telefono);
            u.setEmail(email);

            ModelProveedor model = new ModelProveedor();
            boolean ok = model.saveProveedor(u);

            System.out.println("RESULTADO INSERT SUPPLIER: " + ok);

            response.sendRedirect("dashboard?mod=proveedores");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }
}
