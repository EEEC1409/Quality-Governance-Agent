DELETE FROM contenido_bienvenida WHERE id = 1;
INSERT INTO contenido_bienvenida (id, logo_url, video_url, version, activo)
VALUES (
    1,
    'https://assets.resuelve.com/marca/logo-principal.png',
    'https://assets.resuelve.com/marca/video-bienvenida-v2.mp4',
    '2.1.0',
    TRUE
);
