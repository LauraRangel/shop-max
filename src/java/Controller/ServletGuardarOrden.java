package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ServletGuardarOrden")
public class ServletGuardarOrden extends HttpServlet {

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
            response.sendRedirect("dashboard?mod=compras");
            return;
        }

        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            int idProveedor = Integer.parseInt(request.getParameter("idProveedor"));
            int maxLinea    = Integer.parseInt(request.getParameter("maxLinea"));

            cn = MysqlDBConexion.getConexion();
            cn.setAutoCommit(false);

            // 1. Crear cabecera de la orden
            ps = cn.prepareStatement(
                "INSERT INTO orden_compra (ID_PROVEEDOR, TOTAL, ESTADO) VALUES (?, 0, 'pendiente')",
                Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, idProveedor);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (!rs.next()) throw new Exception("No se generó ID de orden");
            int idOrden = rs.getInt(1);
            rs.close(); ps.close();

            // 2. Insertar líneas de detalle y calcular total
            PreparedStatement psDet = cn.prepareStatement(
                "INSERT INTO detalle_orden (ID_ORDEN, ID_PRODUCTO, CANTIDAD, PRECIO_COMPRA) VALUES (?,?,?,?)");

            double total = 0;
            for (int i = 0; i <= maxLinea; i++) {
                String prodStr  = request.getParameter("item_prod_"   + i);
                String cantStr  = request.getParameter("item_cant_"   + i);
                String precStr  = request.getParameter("item_precio_" + i);
                if (prodStr == null || prodStr.isEmpty()) continue;

                int    idProducto = Integer.parseInt(prodStr);
                int    cantidad   = Integer.parseInt(cantStr);
                double precio     = Double.parseDouble(precStr);
                total += cantidad * precio;

                psDet.setInt(1, idOrden);
                psDet.setInt(2, idProducto);
                psDet.setInt(3, cantidad);
                psDet.setDouble(4, precio);
                psDet.addBatch();
            }
            psDet.executeBatch(); psDet.close();

            // 3. Actualizar total en la cabecera
            ps = cn.prepareStatement(
                "UPDATE orden_compra SET TOTAL = ? WHERE ID_ORDEN = ?");
            ps.setDouble(1, total);
            ps.setInt(2, idOrden);
            ps.executeUpdate();

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

        response.sendRedirect("dashboard?mod=compras");
    }
}
