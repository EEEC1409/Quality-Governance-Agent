package com.resuelve.infraestructura.marca;

import com.resuelve.dominio.marca.ContenidoBienvenida;
import com.resuelve.dominio.marca.IContenidoBienvenidaRepositorio;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
class ContenidoBienvenidaRepositorioJpa implements IContenidoBienvenidaRepositorio {

    private final SpringContenidoBienvenidaJpa springRepo;

    ContenidoBienvenidaRepositorioJpa(SpringContenidoBienvenidaJpa springRepo) {
        this.springRepo = springRepo;
    }

    @Override
    public Optional<ContenidoBienvenida> obtenerActivo() {
        return springRepo.findByActivoTrue()
                .map(e -> new ContenidoBienvenida(e.getLogoUrl(), e.getVideoUrl(), e.getVersion()));
    }
}
