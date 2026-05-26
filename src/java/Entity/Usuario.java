/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Entity;

/**
 *
 * @author laurarangel
 */

public class Usuario {

    private int    id_usuario;
    private int    id_rol;
    private int    id_tienda;
    private String nombre;
    private String email;
    private String contrasena;
    private int    activo;      // renombrado de estado → activo (coincide con BD)

    public int    getId_usuario()         { return id_usuario; }
    public void   setId_usuario(int v)    { this.id_usuario = v; }

    public int    getId_rol()             { return id_rol; }
    public void   setId_rol(int v)        { this.id_rol = v; }

    public int    getId_tienda()          { return id_tienda; }
    public void   setId_tienda(int v)     { this.id_tienda = v; }

    public String getNombre()             { return nombre; }
    public void   setNombre(String v)     { this.nombre = v; }

    public String getEmail()              { return email; }
    public void   setEmail(String v)      { this.email = v; }

    public String getContrasena()         { return contrasena; }
    public void   setContrasena(String v) { this.contrasena = v; }

    public int    getActivo()             { return activo; }
    public void   setActivo(int v)        { this.activo = v; }
}

