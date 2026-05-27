package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ServletRecibirOrden")
public class ServletRecibirOrden extends HttpServlet {

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
            int idOrden   = Integer.parseInt(request.getParameter("idOrden"));
            int numLineas = Integer.parseInt(request.getParameter("numLineas"));
            int idTienda  = (int) session.getAttribute("id_tienda");

            cn = MysqlDBConexion.getConexion();
            cn.setAutoCommit(false);

            // 1. Verificar que la orden no esté anulada ni ya completamente recibida
            ps = cn.prepareStatement(
                "SELECT ESTADO FROM orden_compra WHERE ID_ORDEN = ?");
            ps.setInt(1, idOrden);
            rs = ps.executeQuery();
            if (!rs.next()) throw new Exception("Orden no encontrada");
            String estadoActual = rs.getString("ESTADO");
            if ("anulada".equals(estadoActual))  throw new Exception("Orden anulada");
            if ("recibida".equals(estadoActual)) throw new Exception("Orden ya completamente recibida");
            rs.close(); ps.close();

            // 2. Procesar cada línea recibida
            for (int i = 0; i < numLineas; i++) {
                String prodStr = request.getParameter("item_prod_"     + i);
                String cantStr = request.getParameter("item_recibido_" + i);
                if (prodStr == null || cantStr == null) continue;

                int recibido   = Integer.parseInt(cantStr);
                if (recibido <= 0) continue;
                int idProducto = Integer.parseInt(prodStr);

                // Actualizar cantidad recibida en detalle_orden
                ps = cn.prepareStatement(
                    "UPDATE detalle_orden SET CANTIDAD_RECIBIDA = CANTIDAD_RECIBIDA + ? "
                  + "WHERE ID_ORDEN = ? AND ID_PRODUCTO = ?");
                ps.setInt(1, recibido);
                ps.setInt(2, idOrden);
                ps.setInt(3, idProducto);
                ps.executeUpdate();
                ps.close();

                // Actualizar inventario_tienda
                ps = cn.prepareStatement(
                    "UPDATE inventario_tienda SET CANTIDAD = CANTIDAD + ?, "
                  + "ULTIMA_ACTUALIZACION = NOW() "
                  + "WHERE ID_PRODUCTO = ? AND ID_TIENDA = ?");
                ps.setInt(1, recibido);
                ps.setInt(2, idProducto);
                ps.setInt(3, idTienda);
                int updated = ps.executeUpdate();
                ps.close();

                if (updated == 0) {
                    ps = cn.prepareStatement(
                        "INSERT INTO inventario_tienda (ID_PRODUCTO, ID_TIENDA, CANTIDAD) VALUES (?,?,?)");
                    ps.setInt(1, idProducto);
                    ps.setInt(2, idTienda);
                    ps.setInt(3, recibido);
                    ps.executeUpdate();
                    ps.close();
                }

                // Registrar movimiento
                ps = cn.prepareStatement(
                    "INSERT INTO movimiento_inventario (ID_PRODUCTO, TIPO, CANTIDAD, ORIGEN) "
                  + "VALUES (?, 'entrada', ?, 'compra')");
                ps.setInt(1, idProducto);
                ps.setInt(2, recibido);
                ps.executeUpdate();
                ps.close();
            }

            // 3. Determinar si recepción fue total o parcial
            ps = cn.prepareStatement(
                "SELECT COUNT(*) FROM detalle_orden "
              + "WHERE ID_ORDEN = ? AND CANTIDAD_RECIBIDA < CANTIDAD");
            ps.setInt(1, idOrden);
            rs = ps.executeQuery();
            rs.next();
            String nuevoEstado = (rs.getInt(1) == 0) ? "recibida" : "parcial";
            rs.close(); ps.close();

            ps = cn.prepareStatement(
                "UPDATE orden_compra SET ESTADO = ? WHERE ID_ORDEN = ?");
            ps.setString(1, nuevoEstado);
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
