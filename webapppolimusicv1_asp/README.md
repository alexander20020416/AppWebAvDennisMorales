# AppWebAvDennisMorales — PoliMusic (ASP clásico)

Sitio tipo Spotify (misma estructura, diseño y colores propios) desarrollado en **ASP clásico (.asp)**
con **SQL Server**, HTML + CSS + JavaScript. No usa ASP.NET ni C#.

## 1. Requisitos

- IIS con la característica **ASP** habilitada (Panel de control → Programas → Activar características de Windows → IIS → Desarrollo de aplicaciones → ASP).
- SQL Server con la base **BDD_PoliMusic** ya creada en `localhost` (el sitio no crea ni modifica tablas).
- Proveedor OLE DB `MSOLEDBSQL` (SQL Server 2019/2022/2025). Si no está instalado, en `includes/config.asp` cambie el proveedor por `SQLOLEDB`.

## 2. Publicación en IIS

La carpeta que se publica es **`webapppolimusicv1_asp`** (dentro está todo: `.asp`, `css/`, `js/`,
`includes/` y `SongFilesAndImages_resources/`).

1. Copie la carpeta `webapppolimusicv1_asp` al servidor (por ejemplo `C:\inetpub\wwwroot\PoliMusic`).
2. En el Administrador de IIS: **Sitios → Agregar sitio web**
   - Ruta física: la carpeta `webapppolimusicv1_asp`.
   - Grupo de aplicaciones: **No Managed Code** (DefaultAppPool).
   - Puerto: 8080 (o el que prefiera).
3. Documento predeterminado: `default.asp` (ya incluido en `web.config`).
4. Abra `http://localhost:8080/` → redirige a `login.asp`.

> También puede usar **Visual Studio → Abrir sitio web** y ejecutarlo con IIS Express,
> siempre que la característica ASP esté instalada.

### Estructura de carpetas

```
AppWebAvDennisMorales/
└── webapppolimusicv1_asp/          ← esta carpeta es el sitio
    ├── *.asp
    ├── css/  js/  includes/
    ├── web.config
    └── SongFilesAndImages_resources/
        ├── SongFiles/        (MP3)
        ├── albumImages/  ArtistImages/  UserImages/  PlaylistImages/
        └── BDD_PoliMusic.sql
```

> `includes/config.asp` detecta solo la ubicación de los recursos: sirve tanto si
> `SongFilesAndImages_resources` está dentro de la carpeta del sitio como si está un nivel arriba.

## 3. Conexión a la base de datos

Archivo `includes/config.asp`:

```asp
Const DB_SERVER = "localhost"
Const DB_NAME   = "BDD_PoliMusic"
Const DB_USER   = "usr_polimusic"
Const DB_PASS   = "Politecnica1"
```

Si su instancia es `localhost\SQLEXPRESS`, cambie `DB_SERVER` por `localhost\SQLEXPRESS`.

## 4. Usuarios de prueba

| Usuario          | Contraseña | Rol     |
|------------------|------------|---------|
| `userAdmin`      | `12345678` | Admin   |
| `userNormal`     | `12345678` | Usuario |
| `username1`      | `12345678` | Usuario (contraseña guardada como SHA1) |
| `Dennis.Morales` | `12345678` | Usuario |

El login acepta contraseñas en texto plano y contraseñas cifradas con SHA1
(se comparan con `HASHBYTES('SHA1', ...)` en SQL Server).

## 5. Páginas

| Archivo           | Descripción |
|-------------------|-------------|
| `login.asp`       | Inicio de sesión. Guarda `Session("userId")`, `Session("username")`, `Session("userType")`, `Session("userTypeName")` y `Session("userPhoto")`. |
| `songs.asp`       | Listado de canciones (Song List), mensaje de bienvenida con el usuario de la sesión, reproductor y CRUD para admin. |
| `search.asp`      | Búsqueda por nombre de canción, artista o álbum (usada por el buscador de la barra superior). |
| `library.asp`     | Biblioteca: playlists del usuario, formulario para crear una y playlists públicas de otros usuarios. |
| `playlist.asp`    | Detalle de una playlist con sus canciones, botón Reproducir y opción de eliminarla (solo el dueño). |
| `playlist_create.asp` | Crea la playlist (POST). |
| `playlist_song.asp`   | Agrega o quita una canción de una playlist (POST, valida que sea del usuario). |
| `playlist_delete.asp` | Elimina la playlist y sus relaciones (POST, solo el dueño). |
| `song_form.asp`   | Formulario de alta / edición (solo admin). |
| `song_save.asp`   | Procesa el alta / edición con parámetros ADO y transacción. |
| `song_delete.asp` | Elimina la canción y sus relaciones (solo admin, por POST). |
| `song_play.asp`   | Incrementa el contador `PLAYS` al reproducir. |
| `logout.asp`      | Cierra la sesión (`Session.Abandon`) y vuelve al login. |
| `default.asp`     | Entrada: redirige a `songs.asp` o a `login.asp`. |

Carpeta `includes/`: `config.asp` (conexión), `lib.asp` (helpers y control de roles),
`cards.asp` (consulta y tarjetas de canción reutilizadas por las páginas), `header.asp` y `footer.asp` (layout).

## 6. Recursos (imágenes y audios)

La base de datos guarda rutas con el formato `~/songFiles/archivo.mp3`.
`lib.asp` las convierte a `SongFilesAndImages_resources/...`.

Estructura esperada dentro de `SongFilesAndImages_resources`:

```
SongFilesAndImages_resources/
├── SongFiles/        → bensound-adventure.mp3, bensound-dreams.mp3,
│                       bensound-energy.mp3, bensound-scifi.mp3, bensound-tomorrow.mp3
├── albumImages/      → album1.png … album5.png
├── ArtistImages/     → artist1.jpg … artist5.png
├── UserImages/       → default.jpg, root.png, username1.png
├── PlaylistImages/   → default.jpg, playlist1.png, Playlist2.png, Playlist3.png, Playlist4.png
└── BDD_PoliMusic.sql → script de creación de la base (se verificó contra la base real:
                       9 tablas y las mismas columnas/tipos)
```

> El script `.sql` no se puede descargar desde el navegador (IIS devuelve 404 para esa extensión),
> pero si prefiere no tenerlo en la carpeta publicada, muévalo fuera del sitio.

> Las carpetas están creadas pero vacías. Si un archivo no existe, la interfaz genera
> automáticamente una portada con degradado y la inicial del nombre, para que el diseño
> nunca se vea roto. Al copiar los archivos reales, se muestran sin cambiar código.

### Audio de prueba (temporal)

La carpeta `SongFiles/` **no traía los MP3** (el ZIP de los assets solo contiene carpetas vacías),
así que se generaron 5 pistas de prueba de 24 s y 128 kbps con los nombres exactos que espera la
base de datos:

```
SongFiles/bensound-adventure.mp3
SongFiles/bensound-dreams.mp3
SongFiles/bensound-energy.mp3
SongFiles/bensound-scifi.mp3
SongFiles/bensound-tomorrow.mp3
```

> **Reemplázalos** por los audios reales de los assets (mismo nombre y misma ruta) cuando los
> tengas; no hay que tocar ni el código ni la base de datos. Si un MP3 falta, el reproductor
> muestra un aviso indicando qué archivo no se encontró.

## 7. Roles y permisos

- `USER_TYPE = 0` → **Usuario**: solo puede ver y reproducir canciones.
- `USER_TYPE = 1` → **Administrador**: además ve el botón **Nueva canción** y los iconos
  de editar / eliminar en cada tarjeta.
- Todo el CRUD se valida también en el servidor (`RequireAdmin`), no solo en la interfaz.

## 8. Funcionalidad del reproductor

- Reproducción con `<audio>` (MP3 de los assets).
- Play / pausa, anterior, siguiente, aleatorio y repetir (ninguna / todas / una).
- Barra de progreso con búsqueda por clic y control de volumen.
- Búsqueda en vivo por nombre, artista o álbum y orden por más escuchadas / A-Z.
- Atajos: espacio (play/pausa), flechas (avanzar/retroceder, volumen).

## 9. Playlists y búsqueda

- **Buscar**: el buscador de la barra superior envía a `search.asp?q=...` y busca en el nombre de la
  canción, en el título del álbum y en el nombre/apellido del artista (con parámetros ADO).
- **Biblioteca**: muestra las playlists del usuario, las públicas de otros usuarios y el formulario
  para crear una nueva (pública o privada).
- **Playlist**: cada tarjeta del sidebar abre `playlist.asp?id=N` con sus canciones y el botón
  **Reproducir**. Solo el dueño puede quitar canciones o eliminar la playlist; las privadas de otros
  usuarios redirigen a la biblioteca.
- **Agregar a playlist**: el botón **+** de cada tarjeta (visible al pasar el mouse) abre un modal para
  elegir una playlist existente o crear una nueva en el momento. Evita duplicados.

Todo se guarda en las tablas existentes `TBL_PLAYLIST` y `TBL_PLAYLIST_SONG`; no se crea ninguna tabla.

## 10. Solución de problemas

| Síntoma | Causa / solución |
|---------|------------------|
| La página mostraba *"An error occurred on the server..."* | `IIf()` no existe en VBScript (es de VBA). Ya está implementada en `includes/lib.asp`. |
| Al guardar una canción nueva no se asociaban álbum ni artistas | `SCOPE_IDENTITY()` devolvía 0 porque el `SELECT` iba en otro lote. Ahora el `INSERT` usa `OUTPUT INSERTED.ID_SONG`. |
| Error al guardar los datos relacionados | Se reutilizaba el mismo objeto `ADODB.Command` con varias sentencias. Ahora `NewCmd()` crea un `Command` por sentencia. |
| Las portadas y los MP3 no se ven | La carpeta `SongFilesAndImages_resources` está vacía; copie ahí los archivos de los assets (el ZIP de Descargas solo trae carpetas vacías). |
| `Provider cannot be found` | Instale **Microsoft OLE DB Driver for SQL Server** o cambie el proveedor a `SQLOLEDB` en `includes/config.asp`. |
| Las portadas y los MP3 dan 404 después de mover carpetas | La carpeta publicada debe ser `webapppolimusicv1_asp` y los recursos deben quedar dentro (o un nivel arriba). `config.asp` detecta ambas ubicaciones. |
| El contador de reproducciones subía al abrir la página | Ahora se cuenta una reproducción solo después de 5 segundos reales de escucha. |
