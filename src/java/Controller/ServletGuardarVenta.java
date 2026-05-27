package Controller;

import Utils.MysqlDBConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ServletGuardarVenta")
public class ServletGuardarVenta extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String idClienteStr = request.getParameter("idCliente");
            String tipoPago     = request.getParameter("tipoPago");
            double total        = Double.parseDouble(request.getParameter("total"));
            int    numItems     = Integer.parseInt(request.getParameter("numItems"));

            HttpSession session = request.getSession(false);
            if (session == null) { response.sendRedirect("login"); return; }

            Object idUsuarioObj = session.getAttribute("id_usuario");
            if (idUsuarioObj == null) { response.sendRedirect("login"); return; }
            int idUsuario = Integer.parseInt(idUsuarioObj.toString());

            Object idTiendaObj = session.getAttribute("id_tienda");
            int idTienda = (idTiendaObj != null) ? (Integer) idTiendaObj : 1;

            cn = MysqlDBConexion.getConexion();
            cn.setAutoCommit(false);

            // 1. Insertar venta
            ps = cn.prepareStatement(
                "INSERT INTO venta (ID_CLIENTE, ID_USUARIO, ID_TIENDA, TOTAL, TIPO_PAGO, ESTADO) "
              + "VALUES (?,?,?,?,?,'completada')",
                Statement.RETURN_GENERATED_KEYS);

            if (idClienteStr != null && !idClienteStr.isEmpty())
                ps.setInt(1, Integer.parseInt(idClienteStr));
            else
                ps.setNull(1, Types.INTEGER);

            ps.setInt(2, idUsuario);
            ps.setInt(3, idTienda);
            ps.setDouble(4, total);
            ps.setString(5, tipoPago);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (!rs.next()) throw new Exception("No se generó ID de venta");
            int idVenta = rs.getInt(1);
            rs.close(); ps.close();

            // 2. Insertar líneas de detalle + descontar stock + registrar movimiento
            PreparedStatement psDet = cn.prepareStatement(
                "INSERT INTO detalle_venta (ID_VENTA, ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO, DESCUENTO) "
              + "VALUES (?,?,?,?,0)");

            PreparedStatement psStock = cn.prepareStatement(
                "UPDATE inventario_tienda SET CANTIDAD = CANTIDAD - ?, "
              + "ULTIMA_ACTUALIZACION = NOW() "
              + "WHERE ID_PRODUCTO = ? AND ID_TIENDA = ?");

            PreparedStatement psMov = cn.prepareStatement(
                "INSERT INTO movimiento_inventario (ID_PRODUCTO, TIPO, CANTIDAD, ORIGEN) "
              + "VALUES (?, 'salida', ?, 'venta')");

            for (int i = 0; i < numItems; i++) {
                int    pid  = Integer.parseInt(request.getParameter("item_id_"     + i));
                int    cant = Integer.parseInt(request.getParameter("item_cant_"   + i));
                double prec = Double.parseDouble(request.getParameter("item_precio_" + i));

                psDet.setInt(1, idVenta);
                psDet.setInt(2, pid);
                psDet.setInt(3, cant);
                psDet.setDouble(4, prec);
                psDet.addBatch();

                psStock.setInt(1, cant);
                psStock.setInt(2, pid);
                psStock.setInt(3, idTienda);
                psStock.addBatch();

                psMov.setInt(1, pid);
                psMov.setInt(2, cant);
                psMov.addBatch();
            }
            psDet.executeBatch();   psDet.close();
            psStock.executeBatch(); psStock.close();
            psMov.executeBatch();   psMov.close();

            // 3. Insertar comprobante (boleta automática)
            String numero = "B001-" + String.format("%05d", idVenta);
            PreparedStatement psComp = cn.prepareStatement(
                "INSERT INTO comprobante (ID_VENTA, NUMERO, TIPO) VALUES (?,?,'boleta')");
            psComp.setInt(1, idVenta);
            psComp.setString(2, numero);
            psComp.executeUpdate();
            psComp.close();

            cn.commit();

        } catch (Exception e) {
            e.printStackTrace();
            try { if (cn != null) cn.rollback(); } catch (Exception ex) {}
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (cn != null) { cn.setAutoCommit(true); cn.close(); }
            } catch (Exception e) {}
        }

        response.sendRedirect("dashboard?mod=ventas");
    }
}
