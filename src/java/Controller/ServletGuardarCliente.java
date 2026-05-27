package Controller;

import Entity.Cliente;
import Model.ModelCliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/ServletGuardarCliente")
public class ServletGuardarCliente extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            Cliente c = new Cliente();
            c.setNombre(request.getParameter("nombre"));
            c.setEmail(request.getParameter("email"));
            c.setTelefono(request.getParameter("telefono"));
            c.setDocumento(request.getParameter("documento"));
            c.setFecha_registro(LocalDate.now().toString());
            new ModelCliente().saveCliente(c);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=clientes");
    }
}
