/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Entity;

/**
 *
 * @author USUARIO
 */
public class Cliente {
    
    private int    id_cliente;
    private String nombre;
    private String email;
    private String telefono;
    private String documento;
    private String fecha_registro;
    
    public int    getId_cliente()               { return id_cliente; }
    public void   setId_cliente(int v)          { this.id_cliente = v; }

    public String getNombre()                   { return nombre; }
    public void   setNombre(String v)           { this.nombre = v; }

    public String getEmail()                    { return email; }
    public void   setEmail(String v)            { this.email = v; }

    public String getTelefono()                 { return telefono; }
    public void   setTelefono(String v)         { this.telefono = v; }
    
    public String getDocumento()                { return documento; }
    public void   setDocumento(String v)        { this.documento = v; }

    public String getFecha_registro()           { return fecha_registro; }
    public void   setFecha_registro(String v)   { this.fecha_registro = v; }
}
