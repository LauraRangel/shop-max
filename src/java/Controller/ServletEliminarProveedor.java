package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ServletEliminarProveedor")
public class ServletEliminarProveedor extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Connection cn = null;
        PreparedStatement ps = null;
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement("DELETE FROM proveedor WHERE ID_PROVEEDOR=?");
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (ps != null) ps.close(); if (cn != null) cn.close(); } catch (Exception e) {}
        }
        response.sendRedirect("dashboard?mod=proveedores");
    }
}
