package com.resuelve.unit.marca;

import com.resuelve.dominio.marca.ContenidoBienvenida;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@DisplayName("ContenidoBienvenida — validaciones de dominio")
class ContenidoBienvenidaTest {

    private static final String LOGO_VALIDO = "https://assets.resuelve.com/logo.png";
    private static final String VIDEO_VALIDO = "https://assets.resuelve.com/video.mp4";
    private static final String VERSION_VALIDA = "2.1.0";

    @Test
    @DisplayName("Dado que todos los campos son válidos, Cuando se crea la entidad, Entonces se construye correctamente")
    void debeConstruirConDatosValidos() {
        var contenido = new ContenidoBienvenida(LOGO_VALIDO, VIDEO_VALIDO, VERSION_VALIDA);

        assertThat(contenido.logoUrl()).isEqualTo(LOGO_VALIDO);
        assertThat(contenido.videoUrl()).isEqualTo(VIDEO_VALIDO);
        assertThat(contenido.version()).isEqualTo(VERSION_VALIDA);
    }

    @ParameterizedTest
    @NullAndEmptySource
    @ValueSource(strings = {"  ", "\t"})
    @DisplayName("Dado logoUrl nulo o vacío, Cuando se crea la entidad, Entonces lanza IllegalArgumentException")
    void debeLanzarExcepcionCuandoLogoUrlEsNuloOVacio(String logoUrl) {
        assertThatThrownBy(() -> new ContenidoBienvenida(logoUrl, VIDEO_VALIDO, VERSION_VALIDA))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("logoUrl");
    }

    @Test
    @DisplayName("Dado logoUrl sin prefijo https, Cuando se crea la entidad, Entonces lanza IllegalArgumentException")
    void debeLanzarExcepcionCuandoLogoUrlNoEsHttps() {
        assertThatThrownBy(() -> new ContenidoBienvenida("http://inseguro.com/logo.png", VIDEO_VALIDO, VERSION_VALIDA))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("https://");
    }

    @ParameterizedTest
    @NullAndEmptySource
    @ValueSource(strings = {"  ", "\t"})
    @DisplayName("Dado videoUrl nulo o vacío, Cuando se crea la entidad, Entonces lanza IllegalArgumentException")
    void debeLanzarExcepcionCuandoVideoUrlEsNuloOVacio(String videoUrl) {
        assertThatThrownBy(() -> new ContenidoBienvenida(LOGO_VALIDO, videoUrl, VERSION_VALIDA))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("videoUrl");
    }

    @Test
    @DisplayName("Dado videoUrl sin prefijo https, Cuando se crea la entidad, Entonces lanza IllegalArgumentException")
    void debeLanzarExcepcionCuandoVideoUrlNoEsHttps() {
        assertThatThrownBy(() -> new ContenidoBienvenida(LOGO_VALIDO, "http://inseguro.com/video.mp4", VERSION_VALIDA))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("https://");
    }

    @ParameterizedTest
    @NullAndEmptySource
    @ValueSource(strings = {"  ", "\t"})
    @DisplayName("Dado version nula o vacía, Cuando se crea la entidad, Entonces lanza IllegalArgumentException")
    void debeLanzarExcepcionCuandoVersionEsNulaOVacia(String version) {
        assertThatThrownBy(() -> new ContenidoBienvenida(LOGO_VALIDO, VIDEO_VALIDO, version))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("version");
    }
}
