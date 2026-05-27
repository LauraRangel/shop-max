package Controller;

import Model.ModelReporte;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;

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

        String desde = request.getParameter("desde");
        String hasta = request.getParameter("hasta");
        if (desde == null || desde.isEmpty()) desde = LocalDate.now().withDayOfMonth(1).toString();
        if (hasta == null || hasta.isEmpty()) hasta = LocalDate.now().toString();

        ModelReporte model = new ModelReporte();
        request.setAttribute("ventasPorMes",    model.ventasPorMes());
        request.setAttribute("productosTop",    model.productosTop(desde, hasta));
        request.setAttribute("estadisticas",    model.estadisticas());
        request.setAttribute("kpis",            model.getKpis(desde, hasta));
        request.setAttribute("ventasRecientes", model.getVentasRecientes(desde, hasta));
        request.setAttribute("stockCritico",    model.getStockCritico());
        request.setAttribute("ventasPorPago",   model.getVentasPorPago(desde, hasta));
        request.setAttribute("filtroDesde",     desde);
        request.setAttribute("filtroHasta",     hasta);

        response.sendRedirect("dashboard?mod=reportes&desde=" + desde + "&hasta=" + hasta);
    }
}
