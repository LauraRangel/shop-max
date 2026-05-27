package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ServletGuardarProducto")
public class ServletGuardarProducto extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Connection cn = null;
        PreparedStatement ps = null;
        try {
            int    idCategoria  = Integer.parseInt(request.getParameter("idCategoria"));
            String codigo       = request.getParameter("codigo");
            String nombre       = request.getParameter("nombre");
            double precio       = Double.parseDouble(request.getParameter("precio"));
            int    stockMinimo  = Integer.parseInt(
                request.getParameter("stockMinimo") != null &&
                !request.getParameter("stockMinimo").isEmpty()
                ? request.getParameter("stockMinimo") : "5");

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(
                "INSERT INTO producto (ID_CATEGORIA, CODIGO, NOMBRE, PRECIO, STOCK_MINIMO) VALUES (?,?,?,?,?)");
            ps.setInt(1, idCategoria);
            ps.setString(2, codigo);
            ps.setString(3, nombre);
            ps.setDouble(4, precio);
            ps.setInt(5, stockMinimo);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (ps != null) ps.close(); if (cn != null) cn.close(); } catch (Exception e) {}
        }
        response.sendRedirect("dashboard?mod=inventario");
    }
}
