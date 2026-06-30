package com.resuelve.dominio.marca;

public record ContenidoBienvenida(String logoUrl, String videoUrl, String version) {

    public ContenidoBienvenida {
        if (logoUrl == null || logoUrl.isBlank()) throw new IllegalArgumentException("logoUrl no puede ser vacío");
        if (videoUrl == null || videoUrl.isBlank()) throw new IllegalArgumentException("videoUrl no puede ser vacío");
        if (version == null || version.isBlank()) throw new IllegalArgumentException("version no puede ser vacía");
        if (!logoUrl.startsWith("https://")) throw new IllegalArgumentException("logoUrl debe comenzar con https://");
        if (!videoUrl.startsWith("https://")) throw new IllegalArgumentException("videoUrl debe comenzar con https://");
    }
}
