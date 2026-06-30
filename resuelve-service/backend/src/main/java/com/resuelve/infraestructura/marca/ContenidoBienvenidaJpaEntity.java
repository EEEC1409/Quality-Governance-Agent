package com.resuelve.infraestructura.marca;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "contenido_bienvenida")
public class ContenidoBienvenidaJpaEntity {

    @Id
    private Long id;

    @Column(name = "logo_url", nullable = false, length = 500)
    private String logoUrl;

    @Column(name = "video_url", nullable = false, length = 500)
    private String videoUrl;

    @Column(name = "version", nullable = false, length = 50)
    private String version;

    @Column(name = "activo", nullable = false)
    private boolean activo;

    @Column(name = "creado_en", nullable = false)
    private LocalDateTime creadoEn;

    protected ContenidoBienvenidaJpaEntity() {}

    public Long getId() { return id; }
    public String getLogoUrl() { return logoUrl; }
    public String getVideoUrl() { return videoUrl; }
    public String getVersion() { return version; }
    public boolean isActivo() { return activo; }
    public LocalDateTime getCreadoEn() { return creadoEn; }
}
