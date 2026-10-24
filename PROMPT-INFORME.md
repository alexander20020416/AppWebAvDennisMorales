Actúa como redactor técnico y docente universitario. Escribe el **informe técnico completo** de un proyecto académico de desarrollo web, en español, listo para entregar en Word.

## 1. Contexto del proyecto

**Nombre:** PoliMusic.
**Descripción:** aplicación web tipo Spotify (misma estructura de interfaz, pero con diseño y colores propios) para administrar y reproducir un catálogo de canciones.

**Stack utilizado:**
- Servidor: **ASP clásico (VBScript)** con archivos `.asp` (no se usa ASP.NET ni C#).
- Cliente: HTML5, CSS3 y JavaScript puro.
- Base de datos: **SQL Server**.
- Acceso a datos: **ADO** con proveedor `MSOLEDBSQL`, consultas parametrizadas.
- Servidor web: **IIS 10**.

## 2. Base de datos (existente, no se crea ni modifica ninguna tabla)

Base `BDD_PoliMusic` con 9 tablas:

| Tabla | Columnas |
|---|---|
| TBL_USER | ID_USER, USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE |
| TBL_SONG | ID_SONG, SONG_NAME, SONG_PATH, PLAYS |
| TBL_ALBUM | ID_ALBUM, TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH |
| TBL_ARTIST | ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE |
| TBL_TRACKLIST | ID_ALBUM, ID_SONG |
| TBL_PLAYER | ID_SONG, ID_ARTIST |
| TBL_PLAYLIST | ID_PLAYLIST, ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO |
| TBL_PLAYLIST_SONG | ID_PLAYLIST, ID_SONG |
| TBL_CATALOG | ID_CATALOG, COD_CATALOG_PARENT, COD_CATALOG, VALUE |

**Relaciones:** `TBL_TRACKLIST` relaciona canción y álbum; `TBL_PLAYER` relaciona canción y artista (N:M); `TBL_PLAYLIST_SONG` relaciona playlist y canción (N:M); `TBL_PLAYLIST` pertenece a un usuario.
**Catálogos:** `TBL_CATALOG` define USER TYPE (0 = Usuario, 1 = Administrador) y PLAYLIST TYPE (0 = Pública, 1 = Privada).

## 3. Funcionalidades implementadas

1. **Login** (`login.asp`): valida usuario y contraseña contra `TBL_USER`; acepta contraseña en texto plano o cifrada con SHA1 (comparación con `HASHBYTES('SHA1', ...)`). Guarda en variables de sesión `userId`, `username`, `userType`, `userTypeName` y `userPhoto`.
2. **Cierre de sesión** (`logout.asp`): `Session.Abandon` y regreso al login.
3. **Página de canciones** (`songs.asp`): mensaje de bienvenida con el nombre del usuario leído de la sesión y su rol; texto "Song List" con la leyenda "A continuación se presenta el listado de canciones"; tarjetas con portada, título, artistas, álbum, año y número de reproducciones.
4. **Reproductor**: `<audio>` de HTML5 con play/pausa, anterior, siguiente, aleatorio, repetir (ninguna / todas / una), barra de progreso con búsqueda por clic, control de volumen y atajos de teclado. La reproducción se contabiliza en `PLAYS` después de 5 segundos reales de escucha.
5. **Roles**: usuario normal (solo visualiza y reproduce) y administrador (además crea, edita y elimina canciones). El CRUD se valida en el servidor, no solo en la interfaz.
6. **CRUD de canciones** (solo admin): `song_form.asp`, `song_save.asp`, `song_delete.asp`; guarda y elimina con transacciones y parámetros ADO, y mantiene las relaciones en `TBL_TRACKLIST` y `TBL_PLAYER`.
7. **Búsqueda** (`search.asp`): por nombre de canción, artista o álbum, con `LIKE` parametrizado.
8. **Biblioteca** (`library.asp`): playlists del usuario, playlists públicas de otros usuarios y formulario para crear una nueva (pública o privada).
9. **Playlists** (`playlist.asp`, `playlist_create.asp`, `playlist_song.asp`, `playlist_delete.asp`): ver detalle, reproducir, agregar o quitar canciones (con validación de dueño y control de duplicados) y eliminar la playlist.
10. **Búsqueda y orden en el listado**: filtro en vivo por texto y orden por más escuchadas o alfabético.

## 4. Diseño de interfaz

- Estructura tipo Spotify: barra lateral de navegación, barra superior con buscador, área principal con grilla de tarjetas y reproductor fijo abajo.
- Paleta original: fondo ciruela profundo, acentos coral y ámbar (no se usa el verde de Spotify).
- Componentes propios: tarjetas con acciones al pasar el mouse, chips de filtro, modales, avisos tipo toast y portadas con degradado generado automáticamente cuando falta una imagen.
- Diseño responsivo básico con CSS Grid y Flexbox.

## 5. Seguridad aplicada

- Consultas siempre parametrizadas (sin concatenar datos del usuario).
- Escapado de salida a HTML y a JavaScript con funciones propias.
- Validación de sesión y de rol antes de cada acción protegida.
- Transacciones en las operaciones que afectan varias tablas.

## 6. Qué debe contener el informe

Redáctalo con esta estructura, numerando las secciones:

1. **Portada** (título, asignatura, nombre del estudiante, docente, fecha).
2. **Índice**.
3. **Introducción**: problema, justificación y alcance.
4. **Objetivos**: general y específicos.
5. **Marco teórico**: ASP clásico, modelo cliente-servidor, ADO, SQL Server, sesiones y roles.
6. **Análisis de requisitos**: requisitos funcionales y no funcionales en tablas.
7. **Arquitectura de la solución**: capas (presentación en `.asp`, lógica, acceso a datos), diagrama descrito en texto.
8. **Diseño de la base de datos**: modelo relacional, relaciones, integridad referencial y **diccionario de datos** con una tabla por cada tabla del punto 2 (campo, tipo, nulo, descripción).
9. **Diseño de la interfaz**: descripción de la estructura visual y de la paleta, con marcadores de captura.
10. **Desarrollo de las funcionalidades**: una subsección por cada punto del apartado 3, explicando qué hace, en qué archivo está y cómo se resolvió.
11. **Gestión de roles y seguridad**.
12. **Pruebas realizadas**: tabla de casos (caso, datos de entrada, resultado esperado, resultado obtenido) para login válido e inválido, permisos por rol, alta/edición/eliminación de canción, búsqueda con y sin resultados, creación de playlist, agregar canción duplicada, eliminar playlist.
13. **Conclusiones**.
14. **Recomendaciones y trabajo futuro**.
15. **Bibliografía** (formato APA).
16. **Anexos**: lista de archivos del proyecto y su función.

## 7. Reglas de redacción

- Español formal, en tercera persona, sin primera persona.
- **No inventes** datos, métricas, capturas ni resultados: donde falte una imagen escribe `[CAPTURA: descripción de lo que debe mostrar]`.
- Usa tablas para el diccionario de datos, los requisitos y los casos de prueba.
- Explica el "por qué" de las decisiones técnicas, no solo el "qué".
- Extensión aproximada: 12 a 20 páginas.
- Al final, incluye una tabla resumen de "requisito de la consigna → cómo se cumplió".
