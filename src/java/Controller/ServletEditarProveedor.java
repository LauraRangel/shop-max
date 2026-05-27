package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ServletEditarProveedor")
public class ServletEditarProveedor extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Connection cn = null;
        PreparedStatement ps = null;
        try {
            int    id          = Integer.parseInt(request.getParameter("id"));
            String razonSocial = request.getParameter("razonSocial");
            String ruc         = request.getParameter("ruc");
            String contacto    = request.getParameter("contacto");
            String telefono    = request.getParameter("telefono");
            String email       = request.getParameter("email");

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(
                "UPDATE proveedor SET RAZON_SOCIAL=?, RUC=?, CONTACTO=?, TELEFONO=?, EMAIL=? WHERE ID_PROVEEDOR=?");
            ps.setString(1, razonSocial);
            ps.setString(2, ruc);
            ps.setString(3, contacto);
            ps.setString(4, telefono);
            ps.setString(5, email);
            ps.setInt(6, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (ps != null) ps.close(); if (cn != null) cn.close(); } catch (Exception e) {}
        }
        response.sendRedirect("dashboard?mod=proveedores");
    }
}
