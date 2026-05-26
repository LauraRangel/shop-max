package Controller;

import Model.ModelUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/recuperar")
public class ServletRecuperarPassword extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String from  = request.getParameter("from"); // "perfil" o vacío

        String msg = "Si el correo está registrado, recibirás instrucciones en los próximos minutos.";

        if (email == null || email.trim().isEmpty()) {
            if ("perfil".equals(from)) {
                request.getSession().setAttribute("errorRecuperar", "Ingresa un correo válido.");
                response.sendRedirect("dashboard?mod=perfil");
            } else {
                request.setAttribute("errorRecuperar", "Ingresa un correo válido.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
            return;
        }

        // mismo mensaje siempre por seguridad
        if ("perfil".equals(from)) {
            request.getSession().setAttribute("okRecuperar", msg);
            response.sendRedirect("dashboard?mod=perfil");
        } else {
            request.setAttribute("okRecuperar", msg);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
