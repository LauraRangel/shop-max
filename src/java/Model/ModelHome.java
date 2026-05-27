package Model;

import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.HashMap;

public class ModelHome {

    public HashMap<String, String> getResumen() {

        HashMap<String, String> datos = new HashMap<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            cn = MysqlDBConexion.getConexion();

            // ventas de hoy
            ps = cn.prepareStatement(
                "SELECT COALESCE(SUM(TOTAL), 0) AS total, COUNT(*) AS transacciones " +
                "FROM venta WHERE DATE(FECHA) = CURDATE() AND ESTADO = 'completada'"
            );
            rs = ps.executeQuery();
            if (rs.next()) {
                datos.put("ventasHoy",      String.format("%.2f", rs.getDouble("total")));
                datos.put("transacciones",  rs.getString("transacciones"));
            }
            rs.close(); ps.close();

            // total productos
            ps = cn.prepareStatement("SELECT COUNT(*) AS total FROM producto");
            rs = ps.executeQuery();
            if (rs.next()) datos.put("productos", rs.getString("total"));
            rs.close(); ps.close();

            // total clientes
            ps = cn.prepareStatement("SELECT COUNT(*) AS total FROM cliente");
            rs = ps.executeQuery();
            if (rs.next()) datos.put("clientes", rs.getString("total"));
            rs.close(); ps.close();

        } catch (Exception e) {
            e.printStackTrace();
            datos.put("ventasHoy",     "0.00");
            datos.put("transacciones", "0");
            datos.put("productos",     "0");
            datos.put("clientes",      "0");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (cn != null) cn.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
        return datos;
    }
}
