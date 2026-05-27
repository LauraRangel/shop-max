package Model;

import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

public class ModelCompra {

    public ArrayList<HashMap<String, String>> listarOrdenes() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT oc.ID_ORDEN, pr.RAZON_SOCIAL AS proveedor, oc.FECHA, oc.TOTAL, oc.ESTADO, "
                       + "COUNT(do.ID_DETALLE) AS items "
                       + "FROM orden_compra oc "
                       + "JOIN proveedor pr ON oc.ID_PROVEEDOR = pr.ID_PROVEEDOR "
                       + "LEFT JOIN detalle_orden do ON oc.ID_ORDEN = do.ID_ORDEN "
                       + "GROUP BY oc.ID_ORDEN "
                       + "ORDER BY oc.FECHA DESC";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id", rs.getString("ID_ORDEN"));
                map.put("proveedor", rs.getString("proveedor"));
                map.put("fecha", rs.getString("FECHA"));
                map.put("total", rs.getString("TOTAL"));
                map.put("estado", rs.getString("ESTADO"));
                map.put("items", rs.getString("items"));
                lista.add(map);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (cn != null) cn.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
        return lista;
    }

    public ArrayList<HashMap<String, String>> listarDetallesOrdenes() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT do.ID_ORDEN, do.ID_PRODUCTO, p.NOMBRE AS producto, "
                       + "do.CANTIDAD, do.CANTIDAD_RECIBIDA, do.PRECIO_COMPRA "
                       + "FROM detalle_orden do "
                       + "JOIN producto p ON do.ID_PRODUCTO = p.ID_PRODUCTO "
                       + "ORDER BY do.ID_ORDEN, do.ID_DETALLE";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("idOrden",      rs.getString("ID_ORDEN"));
                map.put("idProducto",   rs.getString("ID_PRODUCTO"));
                map.put("producto",     rs.getString("producto"));
                map.put("cantidad",     rs.getString("CANTIDAD"));
                map.put("recibida",     rs.getString("CANTIDAD_RECIBIDA"));
                map.put("precioCompra", rs.getString("PRECIO_COMPRA"));
                lista.add(map);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (cn != null) cn.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
        return lista;
    }

    public boolean recibirOrden(int idOrden, int idTienda) {
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            cn = MysqlDBConexion.getConexion();
            cn.setAutoCommit(false);

            // 1. Verificar que la orden está pendiente
            ps = cn.prepareStatement(
                "SELECT ESTADO FROM orden_compra WHERE ID_ORDEN = ?");
            ps.setInt(1, idOrden);
            rs = ps.executeQuery();
            if (!rs.next()) throw new Exception("Orden no encontrada");
            if (!"pendiente".equals(rs.getString("ESTADO")))
                throw new Exception("La orden ya fue recibida");
            rs.close(); ps.close();

            // 2. Marcar como recibida
            ps = cn.prepareStatement(
                "UPDATE orden_compra SET ESTADO = 'recibida' WHERE ID_ORDEN = ?");
            ps.setInt(1, idOrden);
            ps.executeUpdate();
            ps.close();

            // 3. Obtener líneas y actualizar inventario
            ps = cn.prepareStatement(
                "SELECT ID_PRODUCTO, CANTIDAD FROM detalle_orden WHERE ID_ORDEN = ?");
            ps.setInt(1, idOrden);
            rs = ps.executeQuery();

            PreparedStatement psUpd = cn.prepareStatement(
                "UPDATE inventario_tienda SET CANTIDAD = CANTIDAD + ?, "
              + "ULTIMA_ACTUALIZACION = NOW() "
              + "WHERE ID_PRODUCTO = ? AND ID_TIENDA = ?");

            PreparedStatement psIns = cn.prepareStatement(
                "INSERT INTO inventario_tienda (ID_PRODUCTO, ID_TIENDA, CANTIDAD) VALUES (?,?,?)");

            PreparedStatement psMov = cn.prepareStatement(
                "INSERT INTO movimiento_inventario (ID_PRODUCTO, TIPO, CANTIDAD, ORIGEN) "
              + "VALUES (?, 'entrada', ?, 'compra')");

            while (rs.next()) {
                int idProducto = rs.getInt("ID_PRODUCTO");
                int cantidad   = rs.getInt("CANTIDAD");

                psUpd.setInt(1, cantidad);
                psUpd.setInt(2, idProducto);
                psUpd.setInt(3, idTienda);
                int updated = psUpd.executeUpdate();

                if (updated == 0) {
                    psIns.setInt(1, idProducto);
                    psIns.setInt(2, idTienda);
                    psIns.setInt(3, cantidad);
                    psIns.executeUpdate();
                }

                psMov.setInt(1, idProducto);
                psMov.setInt(2, cantidad);
                psMov.addBatch();
            }
            rs.close(); ps.close();
            psUpd.close(); psIns.close();
            psMov.executeBatch(); psMov.close();

            cn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (cn != null) cn.rollback(); } catch (Exception ex) {}
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (cn != null) { cn.setAutoCommit(true); cn.close(); }
            } catch (Exception e) { e.printStackTrace(); }
        }
        return false;
    }

    public boolean anularOrden(int idOrden, int idTienda) {
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            cn = MysqlDBConexion.getConexion();
            cn.setAutoCommit(false);

            // 1. Verificar estado actual
            ps = cn.prepareStatement(
                "SELECT ESTADO FROM orden_compra WHERE ID_ORDEN = ?");
            ps.setInt(1, idOrden);
            rs = ps.executeQuery();
            if (!rs.next()) throw new Exception("Orden no encontrada");
            String estadoActual = rs.getString("ESTADO");
            if ("anulada".equals(estadoActual)) throw new Exception("La orden ya está anulada");
            rs.close(); ps.close();

            // 2. Marcar como anulada
            ps = cn.prepareStatement(
                "UPDATE orden_compra SET ESTADO = 'anulada' WHERE ID_ORDEN = ?");
            ps.setInt(1, idOrden);
            ps.executeUpdate();
            ps.close();

            // 3. Si recibida o parcial, revertir solo lo que ya entró al inventario
            if ("recibida".equals(estadoActual) || "parcial".equals(estadoActual)) {
                ps = cn.prepareStatement(
                    "SELECT ID_PRODUCTO, CANTIDAD_RECIBIDA FROM detalle_orden "
                  + "WHERE ID_ORDEN = ? AND CANTIDAD_RECIBIDA > 0");
                ps.setInt(1, idOrden);
                rs = ps.executeQuery();

                PreparedStatement psUpd = cn.prepareStatement(
                    "UPDATE inventario_tienda SET CANTIDAD = CANTIDAD - ?, "
                  + "ULTIMA_ACTUALIZACION = NOW() "
                  + "WHERE ID_PRODUCTO = ? AND ID_TIENDA = ?");

                PreparedStatement psMov = cn.prepareStatement(
                    "INSERT INTO movimiento_inventario (ID_PRODUCTO, TIPO, CANTIDAD, ORIGEN) "
                  + "VALUES (?, 'salida', ?, 'anulacion_compra')");

                while (rs.next()) {
                    int idProducto = rs.getInt("ID_PRODUCTO");
                    int cantidad   = rs.getInt("CANTIDAD_RECIBIDA");

                    psUpd.setInt(1, cantidad);
                    psUpd.setInt(2, idProducto);
                    psUpd.setInt(3, idTienda);
                    psUpd.addBatch();

                    psMov.setInt(1, idProducto);
                    psMov.setInt(2, cantidad);
                    psMov.addBatch();
                }
                rs.close(); ps.close();
                psUpd.executeBatch(); psUpd.close();
                psMov.executeBatch(); psMov.close();
            }

            cn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (cn != null) cn.rollback(); } catch (Exception ex) {}
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (cn != null) { cn.setAutoCommit(true); cn.close(); }
            } catch (Exception e) { e.printStackTrace(); }
        }
        return false;
    }

    public boolean saveOrden(int idProveedor, String total) {
        Connection cn = null;
        PreparedStatement ps = null;

        try {
            String sql = "INSERT INTO orden_compra (ID_PROVEEDOR, TOTAL, ESTADO) "
                       + "VALUES (?, ?, 'pendiente')";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            ps.setInt(1, idProveedor);
            ps.setString(2, total);
            ps.executeUpdate();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
                if (cn != null) cn.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
        return false;
    }
}
