package com.resuelve.adaptadores.marca;

import com.resuelve.dominio.marca.ContenidoBienvenida;
import org.springframework.stereotype.Component;

@Component
public class ContenidoBienvenidaMapper {

    public ContenidoBienvenidaResponse toResponse(ContenidoBienvenida dominio) {
        return new ContenidoBienvenidaResponse(
                dominio.logoUrl(),
                dominio.videoUrl(),
                dominio.version()
        );
    }
}
