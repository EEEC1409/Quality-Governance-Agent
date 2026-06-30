package com.resuelve.unit.marca;

import com.resuelve.aplicacion.marca.ObtenerContenidoBienvenidaUC;
import com.resuelve.dominio.marca.ContenidoBienvenida;
import com.resuelve.dominio.marca.IContenidoBienvenidaRepositorio;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@DisplayName("ObtenerContenidoBienvenidaUC — pruebas unitarias")
class ObtenerContenidoBienvenidaUCTest {

    @Mock
    private IContenidoBienvenidaRepositorio repositorio;

    private ObtenerContenidoBienvenidaUC uc;

    @BeforeEach
    void setUp() {
        uc = new ObtenerContenidoBienvenidaUC(repositorio);
    }

    @Test
    @DisplayName("Dado que el repositorio retorna contenido activo, "
            + "Cuando se ejecuta el UC, "
            + "Entonces devuelve la entidad de dominio correctamente mapeada")
    void debeRetornarContenidoCuandoExisteRegistroActivo() {
        var contenidoEsperado = new ContenidoBienvenida(
                "https://assets.resuelve.com/logo.png",
                "https://assets.resuelve.com/video.mp4",
                "2.1.0"
        );
        when(repositorio.obtenerActivo()).thenReturn(Optional.of(contenidoEsperado));

        var resultado = uc.ejecutar();

        assertThat(resultado.logoUrl()).isEqualTo("https://assets.resuelve.com/logo.png");
        assertThat(resultado.videoUrl()).isEqualTo("https://assets.resuelve.com/video.mp4");
        assertThat(resultado.version()).isEqualTo("2.1.0");
        verify(repositorio).obtenerActivo();
    }

    @Test
    @DisplayName("Dado que el repositorio no retorna contenido, "
            + "Cuando se ejecuta el UC, "
            + "Entonces lanza ContenidoNoEncontradoException")
    void debeLanzarExcepcionCuandoNoExisteContenido() {
        when(repositorio.obtenerActivo()).thenReturn(Optional.empty());

        assertThatThrownBy(() -> uc.ejecutar())
                .isInstanceOf(com.resuelve.dominio.marca.ContenidoNoEncontradoException.class);
        verify(repositorio).obtenerActivo();
    }
}
