package Controller;

import Model.ModelCliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/ServletGuardarCliente")
public class ServletGuardarCliente extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            String nombre    = request.getParameter("nombre");
            String email     = request.getParameter("email");
            String telefono  = request.getParameter("telefono");
            String documento = request.getParameter("documento");
            new ModelCliente().saveCliente(nombre, email, telefono, documento);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=clientes");
    }
}
