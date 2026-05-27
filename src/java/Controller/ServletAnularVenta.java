package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ServletAnularVenta")
public class ServletAnularVenta extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            int idVenta = Integer.parseInt(request.getParameter("idVenta"));

            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("id_usuario") == null) {
                response.sendRedirect("login");
                return;
            }
            String rol = (String) session.getAttribute("rol");
            if (!"Administrador".equals(rol) && !"Gerente de Tienda".equals(rol)) {
                response.sendRedirect("dashboard?mod=ventas");
                return;
            }

            cn = MysqlDBConexion.getConexion();
            cn.setAutoCommit(false);

            // 1. Verificar que la venta está completada y obtener ID_TIENDA
            ps = cn.prepareStatement(
                "SELECT ESTADO, ID_TIENDA FROM venta WHERE ID_VENTA = ?");
            ps.setInt(1, idVenta);
            rs = ps.executeQuery();

            if (!rs.next()) throw new Exception("Venta no encontrada");
            if (!"completada".equals(rs.getString("ESTADO")))
                throw new Exception("La venta ya está anulada");

            int idTienda = rs.getInt("ID_TIENDA");
            rs.close(); ps.close();

            // 2. Cambiar estado de la venta a 'anulada'
            ps = cn.prepareStatement(
                "UPDATE venta SET ESTADO = 'anulada' WHERE ID_VENTA = ?");
            ps.setInt(1, idVenta);
            ps.executeUpdate();
            ps.close();

            // 3. Obtener los detalles para restaurar stock
            ps = cn.prepareStatement(
                "SELECT ID_PRODUCTO, CANTIDAD FROM detalle_venta WHERE ID_VENTA = ?");
            ps.setInt(1, idVenta);
            rs = ps.executeQuery();

            PreparedStatement psStock = cn.prepareStatement(
                "UPDATE inventario_tienda SET CANTIDAD = CANTIDAD + ?, "
              + "ULTIMA_ACTUALIZACION = NOW() "
              + "WHERE ID_PRODUCTO = ? AND ID_TIENDA = ?");

            PreparedStatement psMov = cn.prepareStatement(
                "INSERT INTO movimiento_inventario (ID_PRODUCTO, TIPO, CANTIDAD, ORIGEN) "
              + "VALUES (?, 'entrada', ?, 'anulacion')");

            while (rs.next()) {
                int idProducto = rs.getInt("ID_PRODUCTO");
                int cantidad   = rs.getInt("CANTIDAD");

                // Restaurar stock en inventario_tienda
                psStock.setInt(1, cantidad);
                psStock.setInt(2, idProducto);
                psStock.setInt(3, idTienda);
                psStock.addBatch();

                // Registrar movimiento de entrada por anulación
                psMov.setInt(1, idProducto);
                psMov.setInt(2, cantidad);
                psMov.addBatch();
            }
            rs.close(); ps.close();

            psStock.executeBatch(); psStock.close();
            psMov.executeBatch();   psMov.close();

            cn.commit();

        } catch (Exception e) {
            e.printStackTrace();
            try { if (cn != null) cn.rollback(); } catch (Exception ex) {}
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (cn != null) { cn.setAutoCommit(true); cn.close(); }
            } catch (Exception e) {}
        }

        response.sendRedirect("dashboard?mod=ventas");
    }
}
