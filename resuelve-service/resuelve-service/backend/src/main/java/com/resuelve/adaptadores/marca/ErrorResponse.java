package com.resuelve.adaptadores.marca;

import com.fasterxml.jackson.annotation.JsonProperty;

public record ErrorResponse(
        @JsonProperty("codigo") String codigo,
        @JsonProperty("mensaje") String mensaje,
        @JsonProperty("timestamp") String timestamp
) {}
