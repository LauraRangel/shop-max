package Controller;

import Entity.Cliente;
import Model.ModelCliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/clientes")
public class ServletClientes extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("nombre") == null) {
            response.sendRedirect("login");
            return;
        }

        ModelCliente model = new ModelCliente();
        request.setAttribute("listaClientes", model.listarClientes());

        request.getRequestDispatcher("dashboard").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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
