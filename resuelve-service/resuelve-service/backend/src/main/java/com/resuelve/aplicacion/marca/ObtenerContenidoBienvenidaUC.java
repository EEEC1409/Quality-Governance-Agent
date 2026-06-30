package com.resuelve.aplicacion.marca;

import com.resuelve.dominio.marca.ContenidoBienvenida;
import com.resuelve.dominio.marca.ContenidoNoEncontradoException;
import com.resuelve.dominio.marca.IContenidoBienvenidaRepositorio;
import org.springframework.stereotype.Service;

@Service
public class ObtenerContenidoBienvenidaUC {

    private final IContenidoBienvenidaRepositorio repositorio;

    public ObtenerContenidoBienvenidaUC(IContenidoBienvenidaRepositorio repositorio) {
        this.repositorio = repositorio;
    }

    public ContenidoBienvenida ejecutar() {
        return repositorio.obtenerActivo()
                .orElseThrow(ContenidoNoEncontradoException::new);
    }
}
