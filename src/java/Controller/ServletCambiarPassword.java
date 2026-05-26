package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/CambiarPassword")
public class ServletCambiarPassword extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String actual    = request.getParameter("actual");
        String nueva     = request.getParameter("nueva");
        String confirmar = request.getParameter("confirmar");

        Integer idUsuario = (Integer) request.getSession().getAttribute("id_usuario");

        if (idUsuario == null) {
            response.sendRedirect("login");
            return;
        }

        if (!nueva.equals(confirmar)) {
            request.setAttribute("errorPerfil", "Las contraseñas nuevas no coinciden.");
            request.getRequestDispatcher("dashboard?mod=perfil").forward(request, response);
            return;
        }

        if (nueva.length() < 4) {
            request.setAttribute("errorPerfil", "La nueva contraseña debe tener al menos 4 caracteres.");
            request.getRequestDispatcher("dashboard?mod=perfil").forward(request, response);
            return;
        }

        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            cn = MysqlDBConexion.getConexion();

            // verificar contraseña actual
            ps = cn.prepareStatement(
                "SELECT ID_USUARIO FROM usuario WHERE ID_USUARIO = ? AND PASSWORD_HASH = ?");
            ps.setInt(1, idUsuario);
            ps.setString(2, MysqlDBConexion.hashPassword(actual));
            rs = ps.executeQuery();

            if (!rs.next()) {
                request.setAttribute("errorPerfil", "La contraseña actual es incorrecta.");
                request.getRequestDispatcher("dashboard?mod=perfil").forward(request, response);
                return;
            }

            rs.close();
            ps.close();

            // actualizar con la nueva
            ps = cn.prepareStatement(
                "UPDATE usuario SET PASSWORD_HASH = ? WHERE ID_USUARIO = ?");
            ps.setString(1, MysqlDBConexion.hashPassword(nueva));
            ps.setInt(2, idUsuario);
            ps.executeUpdate();

            request.setAttribute("okPerfil", "Contraseña actualizada correctamente.");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorPerfil", "Error al actualizar la contraseña.");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (cn != null) cn.close();
            } catch (Exception e) { e.printStackTrace(); }
        }

        request.getRequestDispatcher("dashboard?mod=perfil").forward(request, response);
    }
}
