package com.resuelve.adaptadores.marca;

import com.fasterxml.jackson.annotation.JsonProperty;

public record ContenidoBienvenidaResponse(
        @JsonProperty("logoUrl") String logoUrl,
        @JsonProperty("videoUrl") String videoUrl,
        @JsonProperty("version") String version
) {}
