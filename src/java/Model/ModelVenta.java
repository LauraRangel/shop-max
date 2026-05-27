package Model;

import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

public class ModelVenta {

    public ArrayList<HashMap<String, String>> listarVentas() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT v.ID_VENTA, v.FECHA, c.NOMBRE AS cliente, "
                       + "v.TOTAL, v.ESTADO, v.TIPO_PAGO "
                       + "FROM venta v "
                       + "LEFT JOIN cliente c ON v.ID_CLIENTE = c.ID_CLIENTE "
                       + "ORDER BY v.FECHA DESC";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id",       rs.getString("ID_VENTA"));
                map.put("fecha",    rs.getString("FECHA"));
                map.put("cliente",  rs.getString("cliente"));
                map.put("total",    rs.getString("TOTAL"));
                map.put("estado",   rs.getString("ESTADO"));
                map.put("tipoPago", rs.getString("TIPO_PAGO"));
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

    // Trae todos los detalles de todas las ventas en una sola consulta
    public ArrayList<HashMap<String, String>> listarDetalles() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT dv.ID_VENTA, dv.ID_DETALLE, p.NOMBRE AS producto, "
                       + "dv.CANTIDAD, dv.PRECIO_UNITARIO, dv.DESCUENTO, "
                       + "(dv.CANTIDAD * dv.PRECIO_UNITARIO - COALESCE(dv.DESCUENTO,0)) AS subtotal "
                       + "FROM detalle_venta dv "
                       + "JOIN producto p ON dv.ID_PRODUCTO = p.ID_PRODUCTO "
                       + "ORDER BY dv.ID_VENTA, dv.ID_DETALLE";
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("idVenta",       rs.getString("ID_VENTA"));
                map.put("producto",      rs.getString("producto"));
                map.put("cantidad",      rs.getString("CANTIDAD"));
                map.put("precioUnit",    rs.getString("PRECIO_UNITARIO"));
                map.put("descuento",     rs.getString("DESCUENTO"));
                map.put("subtotal",      rs.getString("subtotal"));
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

    // Trae todos los comprobantes indexados por ID_VENTA
    public ArrayList<HashMap<String, String>> listarComprobantes() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT ID_VENTA, NUMERO, TIPO, EMISION FROM comprobante";
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("idVenta",  rs.getString("ID_VENTA"));
                map.put("numero",   rs.getString("NUMERO"));
                map.put("tipo",     rs.getString("TIPO"));
                map.put("emision",  rs.getString("EMISION"));
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

    public boolean saveVenta(String idCliente, int idUsuario, String total, String tipoPago) {
        Connection cn = null;
        PreparedStatement ps = null;

        try {
            String sql = "INSERT INTO venta (ID_CLIENTE, ID_USUARIO, ID_TIENDA, TOTAL, TIPO_PAGO, ESTADO) "
                       + "VALUES (?, ?, 1, ?, ?, 'completada')";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            ps.setString(1, idCliente != null && !idCliente.isEmpty() ? idCliente : null);
            ps.setInt(2, idUsuario);
            ps.setString(3, total);
            ps.setString(4, tipoPago);
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
