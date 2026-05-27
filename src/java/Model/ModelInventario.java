package Model;

import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

public class ModelInventario {

    public ArrayList<HashMap<String, String>> listarInventario() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT p.ID_PRODUCTO, p.CODIGO, p.NOMBRE, p.PRECIO, "
                       + "c.ID_CATEGORIA, c.NOMBRE AS categoria, "
                       + "COALESCE(SUM(it.CANTIDAD), 0) AS stock, p.STOCK_MINIMO "
                       + "FROM producto p "
                       + "JOIN categoria c ON p.ID_CATEGORIA = c.ID_CATEGORIA "
                       + "LEFT JOIN inventario_tienda it ON p.ID_PRODUCTO = it.ID_PRODUCTO "
                       + "GROUP BY p.ID_PRODUCTO "
                       + "ORDER BY p.NOMBRE";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id",          rs.getString("ID_PRODUCTO"));
                map.put("idCategoria", rs.getString("ID_CATEGORIA"));
                map.put("codigo",      rs.getString("CODIGO"));
                map.put("nombre",      rs.getString("NOMBRE"));
                map.put("precio",      rs.getString("PRECIO"));
                map.put("categoria",   rs.getString("categoria"));
                map.put("stock",       rs.getString("stock"));
                map.put("minimo",      rs.getString("STOCK_MINIMO"));
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

    public ArrayList<HashMap<String, String>> listarCategorias() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement("SELECT ID_CATEGORIA, NOMBRE FROM categoria ORDER BY NOMBRE");
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id",     rs.getString("ID_CATEGORIA"));
                map.put("nombre", rs.getString("NOMBRE"));
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

    public boolean registrarEntrada(int idProducto, int cantidad, int idTienda) {
        Connection cn = null;
        PreparedStatement ps = null;

        try {
            cn = MysqlDBConexion.getConexion();
            cn.setAutoCommit(false);

            ps = cn.prepareStatement(
                "INSERT INTO inventario_tienda (ID_PRODUCTO, ID_TIENDA, CANTIDAD) VALUES (?, ?, ?) "
              + "ON DUPLICATE KEY UPDATE CANTIDAD = CANTIDAD + VALUES(CANTIDAD), ULTIMA_ACTUALIZACION = NOW()");
            ps.setInt(1, idProducto);
            ps.setInt(2, idTienda);
            ps.setInt(3, cantidad);
            ps.executeUpdate();
            ps.close();

            ps = cn.prepareStatement(
                "INSERT INTO movimiento_inventario (ID_PRODUCTO, TIPO, CANTIDAD, ORIGEN) "
              + "VALUES (?, 'entrada', ?, 'compra')");
            ps.setInt(1, idProducto);
            ps.setInt(2, cantidad);
            ps.executeUpdate();

            cn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (cn != null) cn.rollback(); } catch (Exception ex) {}
        } finally {
            try {
                if (ps != null) ps.close();
                if (cn != null) { cn.setAutoCommit(true); cn.close(); }
            } catch (Exception e) { e.printStackTrace(); }
        }
        return false;
    }
}
