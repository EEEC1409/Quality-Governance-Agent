package com.resuelve.adaptadores.marca;

import com.resuelve.aplicacion.marca.ObtenerContenidoBienvenidaUC;
import com.resuelve.dominio.marca.ContenidoNoEncontradoException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;

@RestController
@RequestMapping("/v1/marca")
@Tag(name = "Marca", description = "Recursos de identidad y contenido de marca Resuelve")
public class MarcaController {

    private final ObtenerContenidoBienvenidaUC obtenerContenidoUC;
    private final ContenidoBienvenidaMapper mapper;

    public MarcaController(ObtenerContenidoBienvenidaUC obtenerContenidoUC,
                           ContenidoBienvenidaMapper mapper) {
        this.obtenerContenidoUC = obtenerContenidoUC;
        this.mapper = mapper;
    }

    @GetMapping("/contenido-bienvenida")
    @Operation(summary = "Obtener contenido de la pantalla de bienvenida",
               operationId = "obtenerContenidoBienvenida")
    public ResponseEntity<ContenidoBienvenidaResponse> obtenerContenidoBienvenida() {
        var contenido = obtenerContenidoUC.ejecutar();
        return ResponseEntity.ok(mapper.toResponse(contenido));
    }

    @ExceptionHandler(ContenidoNoEncontradoException.class)
    public ResponseEntity<ErrorResponse> handleContenidoNoEncontrado(ContenidoNoEncontradoException ex) {
        return ResponseEntity.status(404).body(new ErrorResponse(
                "CONTENIDO_NO_ENCONTRADO",
                ex.getMessage(),
                Instant.now().toString()
        ));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleError(Exception ex) {
        return ResponseEntity.status(503).body(new ErrorResponse(
                "SERVICIO_NO_DISPONIBLE",
                "El servicio está temporalmente fuera de línea. Intente más tarde.",
                Instant.now().toString()
        ));
    }
}
