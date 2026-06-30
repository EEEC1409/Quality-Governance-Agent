CREATE TABLE contenido_bienvenida (
    id          BIGINT          NOT NULL,
    logo_url    VARCHAR(500)    NOT NULL,
    video_url   VARCHAR(500)    NOT NULL,
    version     VARCHAR(50)     NOT NULL,
    activo      BOOLEAN         NOT NULL DEFAULT TRUE,
    creado_en   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_contenido_bienvenida PRIMARY KEY (id),
    CONSTRAINT ck_logo_url_https  CHECK (logo_url  LIKE 'https://%'),
    CONSTRAINT ck_video_url_https CHECK (video_url LIKE 'https://%')
);
