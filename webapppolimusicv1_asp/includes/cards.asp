<%
' ============================================================
'  cards.asp  -  Consulta y render de las tarjetas de cancion
'  Requiere: lib.asp (H, J, IIf, MediaUrl)
'  Uso:
'     Set rs = cn.Execute(SongSql(""))       ' todas
'     Set rs = cn.Execute(SongSql("s.ID_SONG IN (...)"))
'     RenderSongGrid rs
' ============================================================

' Si es > 0, cada tarjeta muestra el boton "quitar de la playlist"
Dim CARD_PLAYLIST_ID
CARD_PLAYLIST_ID = 0

Function SongSql(whereExtra)
  Dim w
  w = ""
  If Trim(whereExtra & "") <> "" Then w = " WHERE " & whereExtra
  SongSql = "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS,0) AS PLAYS, " & _
            "al.ID_ALBUM, al.TITLE_ALBUM, al.ALBUM_IMAGE_PATH, al.RELEASE_YEAR, " & _
            "ar.ARTIST_NAME, ar.ARTIST_LASTNAME " & _
            "FROM TBL_SONG s " & _
            "OUTER APPLY (SELECT TOP 1 a.ID_ALBUM, a.TITLE_ALBUM, a.ALBUM_IMAGE_PATH, a.RELEASE_YEAR " & _
            "             FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM a ON a.ID_ALBUM = t.ID_ALBUM " & _
            "             WHERE t.ID_SONG = s.ID_SONG ORDER BY a.ID_ALBUM) al " & _
            "LEFT JOIN TBL_PLAYER p ON p.ID_SONG = s.ID_SONG " & _
            "LEFT JOIN TBL_ARTIST ar ON ar.ID_ARTIST = p.ID_ARTIST" & w & _
            " ORDER BY s.ID_SONG, ar.ARTIST_NAME"
End Function

' ------------------------------------------------------------
'  Recorre el recordset (una fila por artista) y agrupa por cancion
' ------------------------------------------------------------
Sub RenderSongGrid(rs)
  Dim curId, curName, curPath, curPlays, curAlbumId, curAlbumTitle
  Dim curAlbumImage, curReleaseYear, curArtists
  curId = -1
  curName = "" : curPath = "" : curPlays = 0
  curAlbumId = "" : curAlbumTitle = "" : curAlbumImage = "" : curReleaseYear = ""
  curArtists = ""

  Do While Not rs.EOF
    If CInt(rs("ID_SONG")) <> curId Then
      If curId <> -1 Then
        Call WriteCard(curId, curName, curPath, curPlays, curAlbumId, curAlbumTitle, curAlbumImage, curReleaseYear, curArtists)
      End If
      curId = CInt(rs("ID_SONG"))
      curName = rs("SONG_NAME")
      curPath = rs("SONG_PATH")
      curPlays = rs("PLAYS")
      If Not IsNull(rs("ID_ALBUM")) Then curAlbumId = rs("ID_ALBUM") Else curAlbumId = ""
      If Not IsNull(rs("TITLE_ALBUM")) Then curAlbumTitle = rs("TITLE_ALBUM") Else curAlbumTitle = ""
      If Not IsNull(rs("ALBUM_IMAGE_PATH")) Then curAlbumImage = rs("ALBUM_IMAGE_PATH") Else curAlbumImage = ""
      If Not IsNull(rs("RELEASE_YEAR")) Then curReleaseYear = rs("RELEASE_YEAR") Else curReleaseYear = ""
      curArtists = ""
    End If
    If Not IsNull(rs("ARTIST_NAME")) Then
      If curArtists <> "" Then curArtists = curArtists & ", "
      curArtists = curArtists & rs("ARTIST_NAME") & " " & rs("ARTIST_LASTNAME")
    End If
    rs.MoveNext
  Loop

  If curId <> -1 Then
    Call WriteCard(curId, curName, curPath, curPlays, curAlbumId, curAlbumTitle, curAlbumImage, curReleaseYear, curArtists)
  End If
End Sub

' ------------------------------------------------------------
'  Tarjeta individual
' ------------------------------------------------------------
Sub WriteCard(id, name, path, plays, albumId, albumTitle, albumImage, releaseYear, artists)
  Dim cover, fallback
  cover = ""
  If Trim(albumImage & "") <> "" Then cover = MediaUrl(albumImage)
  fallback = J(Left(name & "", 1))
  If fallback = "" Then fallback = "?"
%>
<article class="song-card"
  data-id="<%= id %>"
  data-title="<%= H(name) %>"
  data-src="<%= H(MediaUrl(path)) %>"
  data-cover="<%= H(cover) %>"
  data-artist="<%= H(artists) %>"
  data-plays="<%= plays %>">
  <div class="card-art">
    <img src="<%= H(cover) %>" alt="Portada de <%= H(name) %>" loading="lazy" onerror="window.coverFail&&window.coverFail(this,'<%= fallback %>')">
    <button type="button" class="card-play" title="Reproducir <%= H(name) %>" aria-label="Reproducir <%= H(name) %>">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
    </button>
    <div class="card-actions">
      <button type="button" class="card-action" title="Agregar a una playlist" aria-label="Agregar a playlist"
              data-id="<%= id %>" data-name="<%= H(name) %>" onclick="openPlaylistModal(this)">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      </button>
      <% If Session("userType") = 1 Then %>
      <a href="song_form.asp?id=<%= id %>" class="card-action" title="Editar canci&oacute;n" aria-label="Editar">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
      </a>
      <button type="button" class="card-action delete" title="Eliminar canci&oacute;n" aria-label="Eliminar" data-id="<%= id %>" data-name="<%= H(name) %>" onclick="openDelete(this)">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
      </button>
      <% End If %>
      <% If CARD_PLAYLIST_ID > 0 Then %>
      <form method="post" action="playlist_song.asp" class="inline-form">
        <input type="hidden" name="action" value="remove">
        <input type="hidden" name="playlist_id" value="<%= CARD_PLAYLIST_ID %>">
        <input type="hidden" name="song_id" value="<%= id %>">
        <button type="submit" class="card-action delete" title="Quitar de esta playlist" aria-label="Quitar de la playlist">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </button>
      </form>
      <% End If %>
    </div>
    <div class="card-plays">
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="5 3 19 12 5 21 5 3"/></svg>
      <%= plays %>
    </div>
  </div>
  <div class="card-body">
    <h3 class="card-title"><%= H(name) %></h3>
    <p class="card-artist"><%= H(artists) %></p>
    <p class="card-album"><%= H(albumTitle) %><% If Trim(releaseYear & "") <> "" Then %> &bull; <%= releaseYear %><% End If %></p>
  </div>
</article>
<%
End Sub
%>
