package Model;

import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

public class ModelProducto {

    public ArrayList<HashMap<String, String>> listarProductos() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT p.ID_PRODUCTO, p.NOMBRE, p.PRECIO, c.NOMBRE AS categoria, p.STOCK_MINIMO "
                       + "FROM producto p "
                       + "JOIN categoria c ON p.ID_CATEGORIA = c.ID_CATEGORIA "
                       + "ORDER BY p.NOMBRE";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id", rs.getString("ID_PRODUCTO"));
                map.put("nombre", rs.getString("NOMBRE"));
                map.put("precio", rs.getString("PRECIO"));
                map.put("categoria", rs.getString("categoria"));
                map.put("minimo", rs.getString("STOCK_MINIMO"));
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
}
