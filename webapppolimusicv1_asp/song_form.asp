<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<%
' ============================================================
'  song_form.asp  -  Formulario Crear / Editar (solo admin)
' ============================================================
RequireAdmin()

Dim editId, songName, songPath, songPlays, songAlbumId, songArtists
editId = ToInt(Request.QueryString("id"), 0)
songName = "" : songPath = "" : songPlays = 0 : songAlbumId = "" : songArtists = ""

Dim cn, rsAlbums, rsArtists, rsSong, cmd
Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()

Set rsAlbums  = cn.Execute("SELECT ID_ALBUM, TITLE_ALBUM FROM TBL_ALBUM ORDER BY TITLE_ALBUM")
Set rsArtists = cn.Execute("SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME FROM TBL_ARTIST ORDER BY ARTIST_NAME")

If editId > 0 Then
  Set cmd = Server.CreateObject("ADODB.Command")
  cmd.ActiveConnection = cn
  cmd.CommandType = 1
  cmd.CommandText = "SELECT * FROM TBL_SONG WHERE ID_SONG = ?"
  AddParam cmd, "@id", adInteger, 0, editId
  Set rsSong = cmd.Execute()
  If Not rsSong.EOF Then
    songName = rsSong("SONG_NAME")
    songPath = rsSong("SONG_PATH")
    If Not IsNull(rsSong("PLAYS")) Then songPlays = rsSong("PLAYS") Else songPlays = 0
  End If
  rsSong.Close : Set rsSong = Nothing : Set cmd = Nothing

  ' Álbum actual
  Set cmd = Server.CreateObject("ADODB.Command")
  cmd.ActiveConnection = cn
  cmd.CommandType = 1
  cmd.CommandText = "SELECT TOP 1 ID_ALBUM FROM TBL_TRACKLIST WHERE ID_SONG = ?"
  AddParam cmd, "@id", adInteger, 0, editId
  Set rsSong = cmd.Execute()
  If Not rsSong.EOF Then songAlbumId = rsSong("ID_ALBUM")
  rsSong.Close : Set rsSong = Nothing : Set cmd = Nothing

  ' Artistas actuales
  Set cmd = Server.CreateObject("ADODB.Command")
  cmd.ActiveConnection = cn
  cmd.CommandType = 1
  cmd.CommandText = "SELECT ID_ARTIST FROM TBL_PLAYER WHERE ID_SONG = ?"
  AddParam cmd, "@id", adInteger, 0, editId
  Set rsSong = cmd.Execute()
  Do While Not rsSong.EOF
    songArtists = songArtists & rsSong("ID_ARTIST") & ","
    rsSong.MoveNext
  Loop
  rsSong.Close : Set rsSong = Nothing : Set cmd = Nothing
End If

Dim pageTitle, activeNav
pageTitle = IIf(editId > 0, "Editar canción", "Nueva canción")
activeNav = "songs"
%>
<!--#include file="includes/header.asp"-->

<section class="section">
  <div class="section-head">
    <h2><%= H(pageTitle) %></h2>
    <p class="section-desc">Completa los campos y guarda los cambios.</p>
  </div>

  <% If Request.QueryString("err") = "datos" Then %>
  <div class="alert alert-error" style="max-width:720px">El nombre y la ruta del archivo son obligatorios.</div>
  <% End If %>

  <form method="post" action="song_save.asp" class="form-card">
    <input type="hidden" name="id" value="<%= editId %>">

    <div class="form-row">
      <label>
        <span>Nombre de la canci&oacute;n</span>
        <input type="text" name="song_name" value="<%= H(songName) %>" maxlength="50" required>
      </label>
    </div>

    <div class="form-row">
      <label>
        <span>Ruta del archivo</span>
        <input type="text" name="song_path" value="<%= H(songPath) %>" maxlength="255" required placeholder="~/songFiles/mi-cancion.mp3">
        <small class="hint">Ejemplo: ~/songFiles/bensound-adventure.mp3</small>
      </label>
    </div>

    <div class="form-row cols-2">
      <label>
        <span>Reproducciones</span>
        <input type="number" name="plays" value="<%= songPlays %>" min="0">
      </label>
      <label>
        <span>&Aacute;lbum</span>
        <select name="album_id">
          <option value="">(Ninguno)</option>
          <% Do While Not rsAlbums.EOF %>
          <option value="<%= rsAlbums("ID_ALBUM") %>"<%= IIf(CStr(rsAlbums("ID_ALBUM")) = CStr(songAlbumId), " selected", "") %>><%= H(rsAlbums("TITLE_ALBUM")) %></option>
          <% rsAlbums.MoveNext : Loop %>
        </select>
      </label>
    </div>

    <div class="form-row">
      <span class="field-label">Artistas</span>
      <div class="artist-checks">
        <% Do While Not rsArtists.EOF %>
        <label class="check-chip">
          <input type="checkbox" name="artist_ids" value="<%= rsArtists("ID_ARTIST") %>"<%= IIf(InStr("," & songArtists & ",", "," & rsArtists("ID_ARTIST") & ",") > 0, " checked", "") %>>
          <span><%= H(rsArtists("ARTIST_NAME") & " " & rsArtists("ARTIST_LASTNAME")) %></span>
        </label>
        <% rsArtists.MoveNext : Loop %>
      </div>
    </div>

    <div class="form-actions">
      <a href="songs.asp" class="btn btn-ghost">Cancelar</a>
      <button type="submit" class="btn btn-primary">Guardar</button>
    </div>
  </form>
</section>

<%
rsAlbums.Close : Set rsAlbums = Nothing
rsArtists.Close : Set rsArtists = Nothing
cn.Close : Set cn = Nothing
%>
<!--#include file="includes/footer.asp"-->
