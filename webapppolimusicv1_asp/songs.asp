<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<!--#include file="includes/cards.asp"-->
<%
' ============================================================
'  songs.asp  -  Listado de canciones (Song List)
'  Roles: usuario normal (0) y administrador (1)
' ============================================================
RequireLogin()

Dim pageTitle, activeNav
pageTitle = "Canciones"
activeNav = "songs"

Dim cn, rs, rsStats
Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()

' Totales para el encabezado
Set rsStats = cn.Execute("SELECT COUNT(*) AS SONGS, SUM(ISNULL(PLAYS,0)) AS PLAYS FROM TBL_SONG")
Dim totalSongs, totalPlays
totalSongs = 0
totalPlays = 0
If Not rsStats.EOF Then
  totalSongs = rsStats("SONGS")
  If Not IsNull(rsStats("PLAYS")) Then totalPlays = rsStats("PLAYS")
End If
rsStats.Close : Set rsStats = Nothing

Set rs = cn.Execute(SongSql(""))
%>
<!--#include file="includes/header.asp"-->

<div class="hero">
  <div class="hero-bg" aria-hidden="true"></div>
  <div class="hero-inner">
    <div class="hero-avatar">
      <img src="<%= H(MediaUrl(Session("userPhoto"))) %>" alt="" onerror="window.coverFail&&window.coverFail(this,'<%= J(Left(Session("username")&"",1)) %>')">
    </div>
    <div class="hero-info">
      <span class="hero-label">Bienvenido</span>
      <h1><%= H(Session("username")) %></h1>
      <p class="hero-meta">
        <span class="role-pill <%= IIf(Session("userType")=1,"role-admin","role-user") %>"><%= H(Session("userTypeName")) %></span>
        &bull; <%= totalSongs & " " & IIf(totalSongs = 1, "canci&oacute;n", "canciones") %> &bull; <%= totalPlays & " " & IIf(totalPlays = 1, "reproducci&oacute;n", "reproducciones") %>
      </p>
    </div>
    <% If Session("userType") = 1 Then %>
    <a href="song_form.asp" class="btn btn-primary hero-cta">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      Nueva canci&oacute;n
    </a>
    <% End If %>
  </div>
</div>

<section class="section">
  <div class="section-head">
    <h2>Song List</h2>
    <p class="section-desc">A continuaci&oacute;n se presenta el listado de canciones</p>
  </div>

  <div class="chips" id="sortChips">
    <button type="button" class="chip active" data-sort="default">Todos</button>
    <button type="button" class="chip" data-sort="plays">M&aacute;s escuchadas</button>
    <button type="button" class="chip" data-sort="az">A-Z</button>
  </div>

  <div class="song-grid" id="songGrid">
    <% RenderSongGrid rs %>
    <div class="empty-state" id="emptyState" style="display:none">No se encontraron canciones con ese criterio de b&uacute;squeda.</div>
  </div>
</section>

<%
rs.Close : Set rs = Nothing
cn.Close : Set cn = Nothing
%>

<!--#include file="includes/footer.asp"-->
