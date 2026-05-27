/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controller;

import Model.ModelCliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/EditarCliente")
public class ServletEditarCliente extends HttpServlet{
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int    id      = Integer.parseInt(request.getParameter("id"));
            String nombre  = request.getParameter("nombre");
            String email   = request.getParameter("email");
            String telefono   = request.getParameter("telefono");
            String documento   = request.getParameter("documento");

            new ModelCliente().editarCliente(id, nombre, email, telefono, documento);

        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("dashboard?mod=clientes");
    }
}
