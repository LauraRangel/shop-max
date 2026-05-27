package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ServletEliminarProducto")
public class ServletEliminarProducto extends HttpServlet {

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
        if (!"Administrador".equals(rol)) {
            response.sendRedirect("dashboard?mod=inventario");
            return;
        }

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            int idProducto = Integer.parseInt(request.getParameter("idProducto"));

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement("DELETE FROM producto WHERE ID_PRODUCTO = ?");
            ps.setInt(1, idProducto);
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
