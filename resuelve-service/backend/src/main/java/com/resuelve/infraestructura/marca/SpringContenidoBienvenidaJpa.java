package com.resuelve.infraestructura.marca;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

interface SpringContenidoBienvenidaJpa extends JpaRepository<ContenidoBienvenidaJpaEntity, Long> {
    Optional<ContenidoBienvenidaJpaEntity> findByActivoTrue();
}
