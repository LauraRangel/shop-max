package Model;

import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

public class ModelReporte {

    // ── Helpers ──────────────────────────────────────────────────────────────

    private String filtroFecha(String alias) {
        return "AND DATE(" + alias + ".FECHA) BETWEEN ? AND ? ";
    }

    // ── KPIs del período ─────────────────────────────────────────────────────

    public HashMap<String, String> getKpis(String desde, String hasta) {
        HashMap<String, String> kpis = new HashMap<>();
        kpis.put("ventasPeriodo",    "0"); kpis.put("ingresosPeriodo", "0.00");
        kpis.put("stockCritico",     "0"); kpis.put("ordenesPendientes","0");
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            cn = MysqlDBConexion.getConexion();

            ps = cn.prepareStatement(
                "SELECT COUNT(*) AS total, COALESCE(SUM(TOTAL),0) AS ingresos " +
                "FROM venta v WHERE v.ESTADO='completada' " + filtroFecha("v"));
            ps.setString(1, desde); ps.setString(2, hasta);
            rs = ps.executeQuery();
            if (rs.next()) {
                kpis.put("ventasPeriodo",   rs.getString("total"));
                kpis.put("ingresosPeriodo", rs.getString("ingresos"));
            }
            rs.close(); ps.close();

            ps = cn.prepareStatement(
                "SELECT COUNT(*) FROM producto p " +
                "LEFT JOIN (SELECT ID_PRODUCTO, SUM(CANTIDAD) AS s " +
                "           FROM inventario_tienda GROUP BY ID_PRODUCTO) i " +
                "ON p.ID_PRODUCTO = i.ID_PRODUCTO " +
                "WHERE COALESCE(i.s,0) < p.STOCK_MINIMO");
            rs = ps.executeQuery();
            if (rs.next()) kpis.put("stockCritico", rs.getString(1));
            rs.close(); ps.close();

            ps = cn.prepareStatement(
                "SELECT COUNT(*) FROM orden_compra WHERE ESTADO IN ('pendiente','parcial')");
            rs = ps.executeQuery();
            if (rs.next()) kpis.put("ordenesPendientes", rs.getString(1));
            rs.close(); ps.close();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs!=null) rs.close(); if (ps!=null) ps.close(); if (cn!=null) cn.close(); } catch (Exception e) {}
        }
        return kpis;
    }

    // ── Top 10 productos del período ─────────────────────────────────────────

    public ArrayList<HashMap<String, String>> productosTop(String desde, String hasta) {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(
                "SELECT p.NOMBRE, SUM(dv.CANTIDAD) AS cantidad_vendida, " +
                "SUM(dv.CANTIDAD * dv.PRECIO_UNITARIO) AS ingresos " +
                "FROM detalle_venta dv " +
                "JOIN venta v    ON dv.ID_VENTA    = v.ID_VENTA " +
                "JOIN producto p ON dv.ID_PRODUCTO = p.ID_PRODUCTO " +
                "WHERE v.ESTADO='completada' " + filtroFecha("v") +
                "GROUP BY p.ID_PRODUCTO ORDER BY cantidad_vendida DESC LIMIT 10");
            ps.setString(1, desde); ps.setString(2, hasta);
            rs = ps.executeQuery();
            while (rs.next()) {
                HashMap<String, String> m = new HashMap<>();
                m.put("nombre",   rs.getString("NOMBRE"));
                m.put("cantidad", rs.getString("cantidad_vendida"));
                m.put("ingresos", rs.getString("ingresos"));
                lista.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs!=null) rs.close(); if (ps!=null) ps.close(); if (cn!=null) cn.close(); } catch (Exception e) {}
        }
        return lista;
    }

    // ── Ventas recientes del período ─────────────────────────────────────────

    public ArrayList<HashMap<String, String>> getVentasRecientes(String desde, String hasta) {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(
                "SELECT v.ID_VENTA, COALESCE(c.NOMBRE,'Sin cliente') AS cliente, " +
                "u.NOMBRE AS vendedor, v.FECHA, v.TOTAL, v.ESTADO, v.TIPO_PAGO " +
                "FROM venta v " +
                "LEFT JOIN cliente c ON v.ID_CLIENTE = c.ID_CLIENTE " +
                "JOIN usuario u      ON v.ID_USUARIO = u.ID_USUARIO " +
                "WHERE 1=1 " + filtroFecha("v") +
                "ORDER BY v.FECHA DESC LIMIT 50");
            ps.setString(1, desde); ps.setString(2, hasta);
            rs = ps.executeQuery();
            while (rs.next()) {
                HashMap<String, String> m = new HashMap<>();
                m.put("id",       rs.getString("ID_VENTA"));
                m.put("cliente",  rs.getString("cliente"));
                m.put("vendedor", rs.getString("vendedor"));
                m.put("fecha",    rs.getString("FECHA"));
                m.put("total",    rs.getString("TOTAL"));
                m.put("estado",   rs.getString("ESTADO"));
                m.put("tipoPago", rs.getString("TIPO_PAGO"));
                lista.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs!=null) rs.close(); if (ps!=null) ps.close(); if (cn!=null) cn.close(); } catch (Exception e) {}
        }
        return lista;
    }

    // ── Stock crítico (siempre actual, sin filtro de fecha) ──────────────────

    public ArrayList<HashMap<String, String>> getStockCritico() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(
                "SELECT p.NOMBRE, p.CODIGO, cat.NOMBRE AS categoria, " +
                "COALESCE(SUM(it.CANTIDAD),0) AS stock, p.STOCK_MINIMO " +
                "FROM producto p " +
                "JOIN categoria cat ON p.ID_CATEGORIA = cat.ID_CATEGORIA " +
                "LEFT JOIN inventario_tienda it ON p.ID_PRODUCTO = it.ID_PRODUCTO " +
                "GROUP BY p.ID_PRODUCTO " +
                "HAVING stock < p.STOCK_MINIMO ORDER BY stock ASC");
            rs = ps.executeQuery();
            while (rs.next()) {
                HashMap<String, String> m = new HashMap<>();
                m.put("nombre",    rs.getString("NOMBRE"));
                m.put("codigo",    rs.getString("CODIGO"));
                m.put("categoria", rs.getString("categoria"));
                m.put("stock",     rs.getString("stock"));
                m.put("minimo",    rs.getString("STOCK_MINIMO"));
                lista.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs!=null) rs.close(); if (ps!=null) ps.close(); if (cn!=null) cn.close(); } catch (Exception e) {}
        }
        return lista;
    }

    // ── Ventas por forma de pago del período ─────────────────────────────────

    public HashMap<String, String> getVentasPorPago(String desde, String hasta) {
        HashMap<String, String> map = new HashMap<>();
        map.put("efectivo_cantidad","0"); map.put("efectivo_total","0.00");
        map.put("tarjeta_cantidad", "0"); map.put("tarjeta_total", "0.00");
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(
                "SELECT COALESCE(TIPO_PAGO,'otro') AS tipo, COUNT(*) AS cantidad, " +
                "COALESCE(SUM(TOTAL),0) AS total " +
                "FROM venta v WHERE v.ESTADO='completada' " + filtroFecha("v") +
                "GROUP BY TIPO_PAGO");
            ps.setString(1, desde); ps.setString(2, hasta);
            rs = ps.executeQuery();
            while (rs.next()) {
                String tipo = rs.getString("tipo");
                map.put(tipo + "_cantidad", rs.getString("cantidad"));
                map.put(tipo + "_total",    rs.getString("total"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs!=null) rs.close(); if (ps!=null) ps.close(); if (cn!=null) cn.close(); } catch (Exception e) {}
        }
        return map;
    }

    // ── Ventas por mes (últimos 12, sin filtro — visión histórica) ───────────

    public ArrayList<HashMap<String, String>> ventasPorMes() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(
                "SELECT DATE_FORMAT(FECHA,'%Y-%m') AS mes, COUNT(*) AS cantidad, " +
                "SUM(TOTAL) AS total FROM venta " +
                "WHERE ESTADO='completada' " +
                "GROUP BY DATE_FORMAT(FECHA,'%Y-%m') ORDER BY mes DESC LIMIT 12");
            rs = ps.executeQuery();
            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("mes",      rs.getString("mes"));
                map.put("cantidad", rs.getString("cantidad"));
                map.put("total",    rs.getString("total"));
                lista.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs!=null) rs.close(); if (ps!=null) ps.close(); if (cn!=null) cn.close(); } catch (Exception e) {}
        }
        return lista;
    }

    // ── Estadísticas globales (sin filtro) ───────────────────────────────────

    public HashMap<String, String> estadisticas() {
        HashMap<String, String> stats = new HashMap<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            cn = MysqlDBConexion.getConexion();

            ps = cn.prepareStatement("SELECT COUNT(*) AS total, SUM(TOTAL) AS monto FROM venta WHERE ESTADO='completada'");
            rs = ps.executeQuery();
            if (rs.next()) { stats.put("ventasTotal", rs.getString("total")); stats.put("ventasMonto", rs.getString("monto")); }
            rs.close(); ps.close();

            ps = cn.prepareStatement("SELECT COUNT(*) AS total FROM cliente");
            rs = ps.executeQuery();
            if (rs.next()) stats.put("clientesTotal", rs.getString("total"));
            rs.close(); ps.close();

            ps = cn.prepareStatement("SELECT COUNT(*) AS total FROM producto");
            rs = ps.executeQuery();
            if (rs.next()) stats.put("productosTotal", rs.getString("total"));

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs!=null) rs.close(); if (ps!=null) ps.close(); if (cn!=null) cn.close(); } catch (Exception e) {}
        }
        return stats;
    }
}
