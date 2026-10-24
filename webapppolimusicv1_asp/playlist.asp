<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<!--#include file="includes/cards.asp"-->
<%
' ============================================================
'  playlist.asp  -  Detalle de una playlist con sus canciones
' ============================================================
RequireLogin()

Dim pid
pid = ToInt(Request.QueryString("id"), 0)
If pid <= 0 Then Response.Redirect "library.asp"

Dim cn, rsPl, rsCount, rsSongs
Dim plTitle, plPhoto, plType, plOwner, ownerId, isOwner, songCount

Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()

Set rsPl = cn.Execute("SELECT p.ID_PLAYLIST, p.ID_USER, p.TITLE, p.PHOTO, p.TYPE, p.CREATION_DATE, u.USERNAME " & _
                      "FROM TBL_PLAYLIST p INNER JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
                      "WHERE p.ID_PLAYLIST = " & pid)

If rsPl.EOF Then
  rsPl.Close : cn.Close
  Response.Redirect "library.asp"
End If

plTitle = rsPl("TITLE")
plPhoto = rsPl("PHOTO")
plType  = rsPl("TYPE")
plOwner = rsPl("USERNAME")
ownerId = CLng(rsPl("ID_USER"))
isOwner = (ownerId = CLng(Session("userId")))

If Not isOwner And plType <> 0 Then
  rsPl.Close : cn.Close
  Response.Redirect "library.asp?err=" & Server.URLEncode("Esa playlist es privada.")
End If

Set rsCount = cn.Execute("SELECT COUNT(*) AS T FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = " & pid)
songCount = 0
If Not rsCount.EOF Then songCount = rsCount("T")
rsCount.Close : Set rsCount = Nothing

Set rsSongs = cn.Execute(SongSql("s.ID_SONG IN (SELECT ps.ID_SONG FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = " & pid & ")"))

If isOwner Then CARD_PLAYLIST_ID = pid

Dim pageTitle, activeNav
pageTitle = plTitle
activeNav = "library"
%>
<!--#include file="includes/header.asp"-->

<div class="pl-hero">
  <div class="pl-hero-cover">
    <img src="<%= H(MediaUrl(plPhoto)) %>" alt="" onerror="window.coverFail&&window.coverFail(this,'<%= J(Left(plTitle & "",2)) %>')">
  </div>
  <div class="pl-hero-info">
    <span class="pl-type"><%= IIf(plType = 1, "Playlist privada", "Playlist p&uacute;blica") %></span>
    <h1><%= H(plTitle) %></h1>
    <p class="pl-meta">
      <%= H(plOwner) %> &bull; <%= songCount & " " & IIf(songCount = 1, "canci&oacute;n", "canciones") %>
      <% If isOwner Then %> &bull; tu playlist<% End If %>
    </p>
    <div class="pl-actions">
      <% If songCount > 0 Then %>
      <button type="button" class="btn btn-primary" id="playAllBtn">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
        Reproducir
      </button>
      <% End If %>
      <a href="library.asp" class="btn btn-ghost">Volver</a>
      <% If isOwner Then %>
      <form method="post" action="playlist_delete.asp" class="inline-form" onsubmit="return confirm('¿Eliminar la playlist &quot;<%= J(plTitle) %>&quot;?');">
        <input type="hidden" name="id" value="<%= pid %>">
        <button type="submit" class="btn btn-ghost danger">Eliminar playlist</button>
      </form>
      <% End If %>
    </div>
  </div>
</div>

<section class="section">
  <div class="section-head">
    <h2>Canciones</h2>
    <p class="section-desc">
      <% If songCount = 0 Then %>
        Esta playlist est&aacute; vac&iacute;a. Usa el bot&oacute;n <strong>+</strong> de cualquier canci&oacute;n para agregarla.
      <% Else %>
        A continuaci&oacute;n se presenta el listado de canciones de la playlist.
      <% End If %>
    </p>
  </div>

  <div class="song-grid" id="songGrid">
    <% RenderSongGrid rsSongs %>
    <div class="empty-state" id="emptyState"<% If songCount > 0 Then %> style="display:none"<% End If %>>
      Esta playlist no tiene canciones todav&iacute;a.
    </div>
  </div>
</section>

<%
rsSongs.Close : Set rsSongs = Nothing
rsPl.Close : Set rsPl = Nothing
cn.Close : Set cn = Nothing
%>

<!--#include file="includes/footer.asp"-->
