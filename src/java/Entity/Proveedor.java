/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Entity;

/**
 *
 * @author USUARIO
 */
public class Proveedor {
    
    private int    id_proveedor;
    private String razon_social;
    private String ruc;
    private String contacto;
    private String telefono;
    private String email;
    
    public int    getId_proveedor()               { return id_proveedor; }
    public void   setId_proveedor(int v)          { this.id_proveedor = v; }

    public String getRazon_social()               { return razon_social; }
    public void   setRazon_social(String v)       { this.razon_social = v; }

    public String getRuc()                        { return ruc; }
    public void   setRuc(String v)                { this.ruc = v; }

    public String getContacto()                   { return contacto; }
    public void   setContacto(String v)           { this.contacto = v; }
    
    public String getTelefono()                   { return telefono; }
    public void   setTelefono(String v)           { this.telefono = v; }

    public String getEmail()                      { return email; }
    public void   setEmail(String v)              { this.email = v; }
    
}
