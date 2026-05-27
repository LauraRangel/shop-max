package Controller;

import Model.ModelReporte;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/reportes")
public class ServletReportes extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("nombre") == null) {
            response.sendRedirect("login");
            return;
        }

        ModelReporte model = new ModelReporte();

        request.setAttribute("ventasPorMes", model.ventasPorMes());
        request.setAttribute("productosTop", model.productosTop());
        request.setAttribute("estadisticas", model.estadisticas());

        request.getRequestDispatcher("dashboard").forward(request, response);
    }
}
