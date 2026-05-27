
package Controller;

import Entity.Cliente;
import Model.ModelCliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "ServletMantenimientoCliente", urlPatterns = {"/ServletMantenimientoCliente"})
public class ServletMantenimientoCliente extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            System.out.println("REGISTRO CLIENTE");

            String nombre    = request.getParameter("nombre");
            String email     = request.getParameter("email");
            String telefono = request.getParameter("telefono");
            String documento = request.getParameter("documento");
            String fecha_registro = request.getParameter("fecha_registro");

            Cliente u = new Cliente();
            u.setNombre(nombre);
            u.setEmail(email);
            u.setTelefono(telefono);
            u.setDocumento(documento);
            u.setFecha_registro(fecha_registro);

            ModelCliente model = new ModelCliente();
            boolean ok = model.saveCliente(u);

            System.out.println("RESULTADO INSERT CUSTOMER: " + ok);

            response.sendRedirect("dashboard?mod=clientes");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }
}
