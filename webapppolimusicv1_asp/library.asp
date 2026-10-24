<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<%
' ============================================================
'  library.asp  -  Biblioteca del usuario (sus playlists)
' ============================================================
RequireLogin()

Dim pageTitle, activeNav
pageTitle = "Biblioteca"
activeNav = "library"

Dim cn, rsOwn, rsPub, uid
uid = CLng(Session("userId"))

Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()

Set rsOwn = cn.Execute("SELECT p.ID_PLAYLIST, p.TITLE, p.PHOTO, p.TYPE, " & _
                       "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONGS " & _
                       "FROM TBL_PLAYLIST p WHERE p.ID_USER = " & uid & " ORDER BY p.TITLE")

Set rsPub = cn.Execute("SELECT p.ID_PLAYLIST, p.TITLE, p.PHOTO, p.TYPE, u.USERNAME, " & _
                       "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONGS " & _
                       "FROM TBL_PLAYLIST p INNER JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
                       "WHERE p.ID_USER <> " & uid & " AND p.TYPE = 0 ORDER BY p.CREATION_DATE DESC")
%>
<!--#include file="includes/header.asp"-->

<section class="section">
  <div class="section-head">
    <h2>Tu biblioteca</h2>
    <p class="section-desc">Tus playlists y las playlists p&uacute;blicas de la comunidad.</p>
  </div>

  <div class="lib-head">
    <h3 class="lib-title">Tus playlists</h3>
  </div>

  <div class="pl-grid">
    <% Dim hasOwn : hasOwn = False
       Do While Not rsOwn.EOF
         hasOwn = True %>
    <a class="pl-card" href="playlist.asp?id=<%= rsOwn("ID_PLAYLIST") %>">
      <div class="pl-cover">
        <img src="<%= H(MediaUrl(rsOwn("PHOTO"))) %>" alt="" loading="lazy" onerror="window.coverFail&&window.coverFail(this,'<%= J(Left(rsOwn("TITLE")&"",2)) %>')">
        <span class="pl-badge <%= IIf(rsOwn("TYPE")=1,"priv","pub") %>"><%= IIf(rsOwn("TYPE")=1,"Privada","P&uacute;blica") %></span>
      </div>
      <h3><%= H(rsOwn("TITLE")) %></h3>
      <p><%= rsOwn("SONGS") & " " & IIf(rsOwn("SONGS") = 1, "canci&oacute;n", "canciones") %></p>
    </a>
    <% rsOwn.MoveNext : Loop %>
    <% If Not hasOwn Then %>
    <div class="empty-pl">Todav&iacute;a no tienes playlists. Crea la primera abajo.</div>
    <% End If %>
  </div>

  <div class="create-pl" id="nueva">
    <h3 class="lib-title">Crear una playlist</h3>
    <form method="post" action="playlist_create.asp" class="create-pl-form">
      <input type="text" name="title" maxlength="50" placeholder="Nombre de la playlist" required>
      <select name="type">
        <option value="0">P&uacute;blica</option>
        <option value="1">Privada</option>
      </select>
      <button type="submit" class="btn btn-primary">Crear</button>
    </form>
  </div>

  <div class="lib-head">
    <h3 class="lib-title">Playlists p&uacute;blicas</h3>
  </div>

  <div class="pl-grid">
    <% Dim hasPub : hasPub = False
       Do While Not rsPub.EOF
         hasPub = True %>
    <a class="pl-card" href="playlist.asp?id=<%= rsPub("ID_PLAYLIST") %>">
      <div class="pl-cover">
        <img src="<%= H(MediaUrl(rsPub("PHOTO"))) %>" alt="" loading="lazy" onerror="window.coverFail&&window.coverFail(this,'<%= J(Left(rsPub("TITLE")&"",2)) %>')">
        <span class="pl-badge pub">P&uacute;blica</span>
      </div>
      <h3><%= H(rsPub("TITLE")) %></h3>
      <p><%= rsPub("SONGS") & " " & IIf(rsPub("SONGS") = 1, "canci&oacute;n", "canciones") %> &bull; <%= H(rsPub("USERNAME")) %></p>
    </a>
    <% rsPub.MoveNext : Loop %>
    <% If Not hasPub Then %>
    <div class="empty-pl">No hay playlists p&uacute;blicas de otros usuarios.</div>
    <% End If %>
  </div>
</section>

<%
rsOwn.Close : Set rsOwn = Nothing
rsPub.Close : Set rsPub = Nothing
cn.Close : Set cn = Nothing
%>

<!--#include file="includes/footer.asp"-->
