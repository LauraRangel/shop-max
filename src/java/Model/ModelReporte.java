package Model;

import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

public class ModelReporte {

    public ArrayList<HashMap<String, String>> ventasPorMes() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT DATE_FORMAT(FECHA, '%Y-%m') AS mes, COUNT(*) AS cantidad, SUM(TOTAL) AS total "
                       + "FROM venta "
                       + "WHERE ESTADO = 'completada' "
                       + "GROUP BY DATE_FORMAT(FECHA, '%Y-%m') "
                       + "ORDER BY mes DESC "
                       + "LIMIT 12";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("mes", rs.getString("mes"));
                map.put("cantidad", rs.getString("cantidad"));
                map.put("total", rs.getString("total"));
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

    public ArrayList<HashMap<String, String>> productosTop() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT p.NOMBRE, SUM(dv.CANTIDAD) AS cantidad_vendida, SUM(dv.CANTIDAD * dv.PRECIO_UNITARIO) AS ingresos "
                       + "FROM detalle_venta dv "
                       + "JOIN producto p ON dv.ID_PRODUCTO = p.ID_PRODUCTO "
                       + "JOIN venta v ON dv.ID_VENTA = v.ID_VENTA "
                       + "WHERE v.ESTADO = 'completada' "
                       + "GROUP BY p.ID_PRODUCTO "
                       + "ORDER BY cantidad_vendida DESC "
                       + "LIMIT 10";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("nombre", rs.getString("NOMBRE"));
                map.put("cantidad", rs.getString("cantidad_vendida"));
                map.put("ingresos", rs.getString("ingresos"));
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

    public HashMap<String, String> estadisticas() {
        HashMap<String, String> stats = new HashMap<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            cn = MysqlDBConexion.getConexion();

            String sqlVentas = "SELECT COUNT(*) AS total, SUM(TOTAL) AS monto FROM venta WHERE ESTADO = 'completada'";
            ps = cn.prepareStatement(sqlVentas);
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("ventasTotal", rs.getString("total"));
                stats.put("ventasMonto", rs.getString("monto"));
            }
            rs.close();
            ps.close();

            String sqlClientes = "SELECT COUNT(*) AS total FROM cliente";
            ps = cn.prepareStatement(sqlClientes);
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("clientesTotal", rs.getString("total"));
            }
            rs.close();
            ps.close();

            String sqlProductos = "SELECT COUNT(*) AS total FROM producto";
            ps = cn.prepareStatement(sqlProductos);
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("productosTotal", rs.getString("total"));
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
        return stats;
    }
}
