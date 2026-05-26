package Controller;

import Model.ModelUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;

@WebServlet("/login")
public class ServletLogin extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email     = request.getParameter("email");
        String contrasena = request.getParameter("contrasena");

        ModelUsuario model = new ModelUsuario();
        HashMap<String, String> usuario = model.login(email, contrasena);

        if (usuario != null) {
            HttpSession session = request.getSession();
            session.setAttribute("id_usuario", usuario.get("id"));
            session.setAttribute("nombre",     usuario.get("nombre"));
            session.setAttribute("rol",        usuario.get("rol"));
            response.sendRedirect("dashboard");
        } else {
            request.setAttribute("error", "Correo o contraseña incorrectos");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
