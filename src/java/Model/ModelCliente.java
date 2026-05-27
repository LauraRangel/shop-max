package Model;

import Entity.Cliente;
import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

public class ModelCliente {
    
    public ArrayList<HashMap<String, String>> listarClientes() {
        
        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            String sql = "SELECT * FROM cliente";
            
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id", rs.getString("ID_CLIENTE"));
                map.put("nombre", rs.getString("NOMBRE"));
                map.put("email", rs.getString("EMAIL"));
                map.put("telefono", rs.getString("TELEFONO"));
                map.put("documento", rs.getString("DOCUMENTO"));
                map.put("fecha_registro", rs.getString("FECHA_REGISTRO"));
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
    
    public boolean saveCliente(Cliente u) {

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            // CORREGIDO: columna PASSWORD_HASH (no contrasena) y ACTIVO (no estado)
            String sql = "INSERT INTO cliente "
                       + "(NOMBRE, EMAIL, TELEFONO, DOCUMENTO, FECHA_REGISTRO) "
                       + "VALUES (?,?,?,?,?)";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            ps.setString(1,    u.getNombre());
            ps.setString(2,    u.getEmail());
            ps.setString(3, u.getTelefono());
            ps.setString(4, u.getDocumento());
            ps.setString(5, u.getFecha_registro());
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
    
    public boolean editarCliente(int id, String nombre, String email, String telefono, String documento) {
        Connection cn = null;
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE cliente SET NOMBRE=?, EMAIL=?, TELEFONO=?, DOCUMENTO=? WHERE ID_CLIENTE=?";
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, email);
            ps.setString(3, telefono);
            ps.setString(4, documento);
            ps.setInt(5, id);
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
    
    public boolean eliminarCliente(int id) {

        Connection cn = null;
        PreparedStatement ps = null;

        try {

            String sql = "DELETE FROM cliente WHERE ID_CLIENTE = ?";

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
