/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Model;

/**
 *
 * @author laurarangel
 */

import Utils.MysqlDBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

public class ModelTienda {

    public ArrayList<HashMap<String, String>> listarTiendas() {

        ArrayList<HashMap<String, String>> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT ID_TIENDA, NOMBRE FROM tienda";
            cn = MysqlDBConexion.getConexion();
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("id",     rs.getString("ID_TIENDA"));
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
}
