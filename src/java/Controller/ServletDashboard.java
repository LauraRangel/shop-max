/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controller;

/**
 *
 * @author laurarangel
 */

import Model.ModelCliente;
import Model.ModelReporte;
import java.time.LocalDate;
import Model.ModelCompra;
import Model.ModelHome;
import Model.ModelInventario;
import Model.ModelProveedor;
import Model.ModelRol;
import Model.ModelTienda;
import Model.ModelUsuario;
import Model.ModelVenta;
import Model.ModelProducto;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/dashboard")
public class ServletDashboard extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("nombre") == null) {
            response.sendRedirect("login");
            return;
        }

        String mod = request.getParameter("mod");
        if (mod == null) mod = "home";

        // datos siempre necesarios (sidebar, usuarios)
        request.setAttribute("proveedores",    new ModelProveedor().listarProveedores());
        request.setAttribute("clientes",    new ModelCliente().listarClientes());
        request.setAttribute("roles",    new ModelRol().listarRoles());
        request.setAttribute("tiendas",  new ModelTienda().listarTiendas());
        request.setAttribute("usuarios", new ModelUsuario().listarUsuarios());
        request.setAttribute("resumen",  new ModelHome().getResumen());

        // datos por módulo
        switch (mod) {
            case "ventas":
                ModelVenta mv = new ModelVenta();
                request.setAttribute("listaVentas",       mv.listarVentas());
                request.setAttribute("listaDetalles",     mv.listarDetalles());
                request.setAttribute("listaComprobantes", mv.listarComprobantes());
                request.setAttribute("listaProductos",    new ModelProducto().listarProductos());
                request.setAttribute("listaClientes",     new ModelCliente().listarClientes());
                break;
            case "inventario":
                request.setAttribute("listaProductos",   new ModelInventario().listarInventario());
                request.setAttribute("listaCategorias",  new ModelInventario().listarCategorias());
                break;
            case "compras":
                request.setAttribute("listaOrdenes",       new ModelCompra().listarOrdenes());
                request.setAttribute("listaDetallesOrden",  new ModelCompra().listarDetallesOrdenes());
                request.setAttribute("listaProveedores",    new ModelProveedor().listarProveedores());
                request.setAttribute("listaProductos",      new ModelProducto().listarProductos());
                break;
            case "clientes":
                request.setAttribute("listaClientes", new ModelCliente().listarClientes());
                break;
            case "proveedores":
                request.setAttribute("listaProveedores", new ModelProveedor().listarProveedores());
                break;
            case "reportes":
                String desde = request.getParameter("desde");
                String hasta = request.getParameter("hasta");
                if (desde == null || desde.isEmpty())
                    desde = LocalDate.now().withDayOfMonth(1).toString();
                if (hasta == null || hasta.isEmpty())
                    hasta = LocalDate.now().toString();
                ModelReporte mr = new ModelReporte();
                request.setAttribute("kpis",            mr.getKpis(desde, hasta));
                request.setAttribute("topProductos",    mr.productosTop(desde, hasta));
                request.setAttribute("ventasRecientes", mr.getVentasRecientes(desde, hasta));
                request.setAttribute("stockCritico",    mr.getStockCritico());
                request.setAttribute("ventasPorPago",   mr.getVentasPorPago(desde, hasta));
                request.setAttribute("ventasPorMes",    mr.ventasPorMes());
                request.setAttribute("filtroDesde",     desde);
                request.setAttribute("filtroHasta",     hasta);
                break;
        }

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}
