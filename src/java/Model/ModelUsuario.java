package Model;

import Entity.Usuario;
import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

public class ModelUsuario {

    // listar todos los usuarios con JOIN a rol y tienda
    public ArrayList<HashMap<String, String>> listarUsuarios() {

        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT u.ID_USUARIO, u.NOMBRE, u.EMAIL, "
                       + "r.NOMBRE AS ROL, t.NOMBRE AS TIENDA, u.ACTIVO "
                       + "FROM usuario u "
                       + "JOIN rol r    ON u.ID_ROL    = r.ID_ROL "
                       + "JOIN tienda t ON u.ID_TIENDA = t.ID_TIENDA";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id",     rs.getString("ID_USUARIO"));
                map.put("nombre", rs.getString("NOMBRE"));
                map.put("email",  rs.getString("EMAIL"));
                map.put("rol",    rs.getString("ROL"));
                map.put("tienda", rs.getString("TIENDA"));
                map.put("activo", rs.getString("ACTIVO"));
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

    // guardar nuevo usuario — mantiene la esencia del saveUsuario original
    public boolean saveUsuario(Usuario u) {

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            // CORREGIDO: columna PASSWORD_HASH (no contrasena) y ACTIVO (no estado)
            String sql = "INSERT INTO usuario "
                       + "(ID_ROL, ID_TIENDA, NOMBRE, EMAIL, PASSWORD_HASH, ACTIVO) "
                       + "VALUES (?,?,?,?,?,1)";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            ps.setInt(1,    u.getId_rol());
            ps.setInt(2,    u.getId_tienda());
            ps.setString(3, u.getNombre());
            ps.setString(4, u.getEmail());
            ps.setString(5, MysqlDBConexion.hashPassword(u.getContrasena()));
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

    // buscar usuario por email y contraseña (para login)
    public HashMap<String, String> login(String email, String contrasena) {

        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT u.ID_USUARIO, u.NOMBRE, r.NOMBRE AS ROL, u.ID_TIENDA "
                       + "FROM usuario u JOIN rol r ON u.ID_ROL = r.ID_ROL "
                       + "WHERE u.EMAIL = ? AND u.PASSWORD_HASH = ? AND u.ACTIVO = 1";

            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, MysqlDBConexion.hashPassword(contrasena));
            rs = ps.executeQuery();

            if (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id",       rs.getString("ID_USUARIO"));
                map.put("nombre",   rs.getString("NOMBRE"));
                map.put("rol",      rs.getString("ROL"));
                map.put("idTienda", rs.getString("ID_TIENDA"));
                return map;
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
        return null;
    }

    public boolean desactivarUsuario(int id) {
        Connection cn = null;
        PreparedStatement ps = null;
        try {
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement("UPDATE usuario SET ACTIVO = 0 WHERE ID_USUARIO = ?");
            ps.setInt(1, id);
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

    public boolean existeEmail(String email) {
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement("SELECT ID_USUARIO FROM usuario WHERE EMAIL = ?");
            ps.setString(1, email);
            rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (cn != null) cn.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
        return false;
    }

    public boolean editarUsuario(int id, String nombre, String email, int idRol, int idTienda, int activo) {
        Connection cn = null;
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE usuario SET NOMBRE=?, EMAIL=?, ID_ROL=?, ID_TIENDA=?, ACTIVO=? WHERE ID_USUARIO=?";
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, email);
            ps.setInt(3, idRol);
            ps.setInt(4, idTienda);
            ps.setInt(5, activo);
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
}
