package Model;

import Entity.Proveedor;
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
            String sql = "SELECT * FROM proveedor";
            
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id", rs.getString("ID_PROVEEDOR"));
                map.put("razon_social", rs.getString("RAZON_SOCIAL"));
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
    
    public boolean saveProveedor(Proveedor u) {

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            // CORREGIDO: columna PASSWORD_HASH (no contrasena) y ACTIVO (no estado)
            String sql = "INSERT INTO proveedor "
                       + "(RAZON_SOCIAL, RUC, CONTACTO, TELEFONO, EMAIL) "
                       + "VALUES (?,?,?,?,?)";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            ps.setString(1,    u.getRazon_social());
            ps.setString(2,    u.getRuc());
            ps.setString(3, u.getContacto());
            ps.setString(4, u.getTelefono());
            ps.setString(5, u.getEmail());
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
    
    public boolean editarProveedor(int id, String razon_social, String ruc, String contacto, String telefono, String email) {
        Connection cn = null;
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE proveedor SET RAZON_SOCIAL=?, RUC=?, CONTACTO=?, TELEFONO=?, EMAIL=? WHERE ID_PROVEEDOR=?";
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            ps.setString(1, razon_social);
            ps.setString(2, ruc);
            ps.setString(3, contacto);
            ps.setString(4, telefono);
            ps.setString(5, email);
            ps.setInt(6, id);
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
    
    public boolean eliminarProveedor(int id) {

        Connection cn = null;
        PreparedStatement ps = null;

        try {

            String sql = "DELETE FROM proveedor WHERE ID_PROVEEDOR = ?";

            cn = MysqlDBConexion.getConexion();

            ps = cn.prepareStatement(sql);

            ps.setInt(1, id);

            ps.executeUpdate();

            return true;

        } catch (Exception e) {

            e.printStackTrace();

        } finally {

            try {

                if (ps != null) ps.close();

                if (cn != null) cn.close();

            } catch (Exception e) {

                e.printStackTrace();
            }
        }

        return false;
    }
}
