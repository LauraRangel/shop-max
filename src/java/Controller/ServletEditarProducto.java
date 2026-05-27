package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ServletEditarProducto")
public class ServletEditarProducto extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("id_usuario") == null) {
            response.sendRedirect("login");
            return;
        }
        String rol = (String) session.getAttribute("rol");
        if (!"Administrador".equals(rol) && !"Gerente de Tienda".equals(rol)) {
            response.sendRedirect("dashboard?mod=inventario");
            return;
        }

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            int    idProducto  = Integer.parseInt(request.getParameter("idProducto"));
            int    idCategoria = Integer.parseInt(request.getParameter("idCategoria"));
            String codigo      = request.getParameter("codigo");
            String nombre      = request.getParameter("nombre");
            double precio      = Double.parseDouble(request.getParameter("precio"));
            String smParam     = request.getParameter("stockMinimo");
            int    stockMinimo = (smParam != null && !smParam.isEmpty()) ? Integer.parseInt(smParam) : 5;

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(
                "UPDATE producto SET ID_CATEGORIA=?, CODIGO=?, NOMBRE=?, PRECIO=?, STOCK_MINIMO=? WHERE ID_PRODUCTO=?");
            ps.setInt(1, idCategoria);
            ps.setString(2, codigo);
            ps.setString(3, nombre);
            ps.setDouble(4, precio);
            ps.setInt(5, stockMinimo);
            ps.setInt(6, idProducto);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
                if (cn != null) cn.close();
            } catch (Exception e) {}
        }

        response.sendRedirect("dashboard?mod=inventario");
    }
}
