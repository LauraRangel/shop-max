package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ServletEditarCliente")
public class ServletEditarCliente extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Connection cn = null;
        PreparedStatement ps = null;
        try {
            int    id        = Integer.parseInt(request.getParameter("id"));
            String nombre    = request.getParameter("nombre");
            String email     = request.getParameter("email");
            String telefono  = request.getParameter("telefono");
            String documento = request.getParameter("documento");

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(
                "UPDATE cliente SET NOMBRE=?, EMAIL=?, TELEFONO=?, DOCUMENTO=? WHERE ID_CLIENTE=?");
            ps.setString(1, nombre);
            ps.setString(2, email);
            ps.setString(3, telefono);
            ps.setString(4, documento);
            ps.setInt(5, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (ps != null) ps.close(); if (cn != null) cn.close(); } catch (Exception e) {}
        }
        response.sendRedirect("dashboard?mod=clientes");
    }
}
