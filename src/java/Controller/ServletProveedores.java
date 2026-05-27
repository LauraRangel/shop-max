package Controller;

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
            String razonSocial = request.getParameter("razonSocial");
            String ruc = request.getParameter("ruc");
            String contacto = request.getParameter("contacto");
            String telefono = request.getParameter("telefono");
            String email = request.getParameter("email");

            ModelProveedor model = new ModelProveedor();
            model.saveProveedor(razonSocial, ruc, contacto, telefono, email);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=proveedores");
    }
}
