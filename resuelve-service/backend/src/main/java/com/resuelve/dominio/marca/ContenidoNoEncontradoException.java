package com.resuelve.dominio.marca;

public class ContenidoNoEncontradoException extends RuntimeException {
    public ContenidoNoEncontradoException() {
        super("No existe contenido de bienvenida activo configurado.");
    }
}
