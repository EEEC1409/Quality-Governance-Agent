package com.resuelve.functional.marca.bdd.steps;

import io.cucumber.java.es.Cuando;
import io.cucumber.java.es.Dado;
import io.cucumber.java.es.Entonces;
import io.cucumber.java.es.Y;
import io.restassured.RestAssured;
import io.restassured.module.jsv.JsonSchemaValidator;
import io.restassured.response.Response;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.jdbc.core.JdbcTemplate;

import static org.assertj.core.api.Assertions.assertThat;

public class ContenidoBienvenidaSteps {

    @LocalServerPort
    private int port;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private Response respuesta;

    @Dado("que existe contenido de bienvenida activo en la base de datos")
    public void existeContenidoActivo() {
        jdbcTemplate.update(
                "UPDATE contenido_bienvenida SET activo = TRUE WHERE id = 1"
        );
    }

    @Dado("que no existe ningún registro activo en la base de datos")
    public void noExisteContenidoActivo() {
        jdbcTemplate.update("UPDATE contenido_bienvenida SET activo = FALSE");
    }

    @Cuando("^se realiza GET /v1/marca/contenido-bienvenida$")
    public void realizarGet() {
        respuesta = RestAssured
                .given()
                .baseUri("http://localhost:" + port)
                .when()
                .get("/v1/marca/contenido-bienvenida");
    }

    @Entonces("la respuesta tiene código HTTP {int}")
    public void verificarCodigoHttp(int codigoEsperado) {
        assertThat(respuesta.getStatusCode()).isEqualTo(codigoEsperado);
    }

    @Y("el cuerpo contiene logoUrl, videoUrl y version")
    public void verificarCamposRespuesta() {
        assertThat(respuesta.jsonPath().getString("logoUrl")).isNotBlank();
        assertThat(respuesta.jsonPath().getString("videoUrl")).isNotBlank();
        assertThat(respuesta.jsonPath().getString("version")).isNotBlank();
    }

    @Y("el cuerpo cumple el esquema OpenAPI de ContenidoBienvenidaResponse")
    public void verificarEsquemaOpenApi() {
        respuesta.then().assertThat()
                .body(JsonSchemaValidator.matchesJsonSchemaInClasspath(
                        "contracts/contenido_bienvenida_response_schema.json"));
    }

    @Y("el cuerpo contiene el campo codigo con valor {string}")
    public void verificarCodigoError(String codigoEsperado) {
        assertThat(respuesta.jsonPath().getString("codigo")).isEqualTo(codigoEsperado);
    }
}
