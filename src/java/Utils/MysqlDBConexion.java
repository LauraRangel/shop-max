/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Utils;

/**
 *
 * @author laurarangel
 */

import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.DriverManager;

public class MysqlDBConexion {

    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(password.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes)
                sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return password;
        }
    }

    public static Connection getConexion() {
        Connection cn = null;
        try {
            // CORREGIDO: driver actualizado para mysql-connector-j-9.6.0
            Class.forName("com.mysql.cj.jdbc.Driver");
            cn = DriverManager.getConnection(
                "jdbc:mysql://localhost/shopmax?useSSL=false&serverTimezone=UTC",
                "root", ""
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
        return cn;
    }
}
