package Model;

import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

public class ModelProveedor {

    public ArrayList<HashMap<String, String>> listarProveedores() {
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT ID_PROVEEDOR, RAZON_SOCIAL, RUC, CONTACTO, TELEFONO, EMAIL "
                       + "FROM proveedor "
                       + "ORDER BY RAZON_SOCIAL";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id", rs.getString("ID_PROVEEDOR"));
                map.put("nombre", rs.getString("RAZON_SOCIAL"));
                map.put("ruc", rs.getString("RUC"));
                map.put("contacto", rs.getString("CONTACTO"));
                map.put("telefono", rs.getString("TELEFONO"));
                map.put("email", rs.getString("EMAIL"));
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

    public boolean saveProveedor(String razonSocial, String ruc, String contacto, String telefono, String email) {
        Connection cn = null;
        PreparedStatement ps = null;

        try {
            String sql = "INSERT INTO proveedor (RAZON_SOCIAL, RUC, CONTACTO, TELEFONO, EMAIL) "
                       + "VALUES (?, ?, ?, ?, ?)";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            ps.setString(1, razonSocial);
            ps.setString(2, ruc);
            ps.setString(3, contacto);
            ps.setString(4, telefono);
            ps.setString(5, email);
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
