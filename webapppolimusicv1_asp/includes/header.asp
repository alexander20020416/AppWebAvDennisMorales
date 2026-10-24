<%
' ============================================================
'  header.asp  -  Cabecera, barra lateral y barra superior
'  Variables esperadas: pageTitle, activeNav
' ============================================================
If IsEmpty(pageTitle) Then pageTitle = APP_NAME
If IsEmpty(activeNav) Then activeNav = "songs"
If IsEmpty(extraHead) Then extraHead = ""

Dim hdrCn, hdrRsOwn, hdrRsPub, hdrUid, hdrHasOwn, hdrPubStarted, plOptions
hdrUid = CLng(Session("userId"))
plOptions = ""
hdrHasOwn = False
hdrPubStarted = False

Set hdrCn = Server.CreateObject("ADODB.Connection")
hdrCn.Open ConnString()

' Playlists del usuario
Set hdrRsOwn = hdrCn.Execute("SELECT p.ID_PLAYLIST, p.TITLE, p.PHOTO, p.TYPE, " & _
                        "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONGS " & _
                        "FROM TBL_PLAYLIST p WHERE p.ID_USER = " & hdrUid & " ORDER BY p.TITLE")

' Playlists publicas de otros usuarios
Set hdrRsPub = hdrCn.Execute("SELECT TOP 6 p.ID_PLAYLIST, p.TITLE, p.PHOTO, p.TYPE, " & _
                         "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONGS " & _
                         "FROM TBL_PLAYLIST p WHERE p.ID_USER <> " & hdrUid & " AND p.TYPE = 0 " & _
                         "ORDER BY p.CREATION_DATE DESC")
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= H(pageTitle) %> &mdash; <%= H(APP_NAME) %></title>
<link rel="stylesheet" href="css/styles.css">
<script>
/* Fallback de portadas: se define antes de cargar las imágenes */
window.coverFail = function(img, label){
  if (img.dataset.fallback) return;
  img.dataset.fallback = '1';
  var l = (label || '\u266A').toString();
  var code = l.charCodeAt(0) || 0;
  var hue = ((code * 37) + (l.length > 1 ? l.charCodeAt(1) * 13 : 0)) % 360;
  var hue2 = (hue + 40) % 360;
  var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="400">' +
    '<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">' +
    '<stop offset="0%" stop-color="hsl(' + hue + ',80%,58%)"/>' +
    '<stop offset="100%" stop-color="hsl(' + hue2 + ',70%,44%)"/></linearGradient></defs>' +
    '<rect width="400" height="400" fill="url(#g)"/>' +
    '<text x="200" y="260" font-size="160" fill="rgba(255,255,255,.92)" text-anchor="middle" ' +
    'font-family="-apple-system,Segoe UI,sans-serif" font-weight="700">' +
    l.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') +
    '</text></svg>';
  img.src = 'data:image/svg+xml;base64,' + btoa(svg);
};
</script>
<%= extraHead %>
</head>
<body>
<div class="app">
  <aside class="sidebar">
    <a href="songs.asp" class="logo">
      <span class="logo-icon" aria-hidden="true">
        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M12 8v8"/><path d="M8 12l4 4 4-4"/></svg>
      </span>
      <span class="logo-text"><%= H(APP_NAME) %></span>
    </a>
    <nav class="nav">
      <a href="songs.asp" class="nav-item<%= IIf(activeNav="songs"," active","") %>">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        Inicio
      </a>
      <a href="search.asp" class="nav-item<%= IIf(activeNav="search"," active","") %>">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        Buscar
      </a>
      <a href="library.asp" class="nav-item<%= IIf(activeNav="library"," active","") %>">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
        Biblioteca
      </a>
    </nav>

    <div class="sidebar-section">
      <div class="sidebar-head">
        <span>Tus playlists</span>
        <a href="library.asp#nueva" class="sidebar-plus" title="Crear playlist" aria-label="Crear playlist">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </a>
      </div>
      <ul class="playlist-list">
        <% Do While Not hdrRsOwn.EOF
             hdrHasOwn = True
             plOptions = plOptions & "<option value=""" & hdrRsOwn("ID_PLAYLIST") & """>" & H(hdrRsOwn("TITLE")) & "</option>" %>
        <li class="playlist-item">
          <a href="playlist.asp?id=<%= hdrRsOwn("ID_PLAYLIST") %>">
            <img class="playlist-thumb" src="<%= H(MediaUrl(hdrRsOwn("PHOTO"))) %>" alt="" loading="lazy" onerror="window.coverFail&&window.coverFail(this,'<%= J(Left(hdrRsOwn("TITLE")&"",2)) %>')">
            <span class="playlist-name"><%= H(hdrRsOwn("TITLE")) %></span>
            <span class="playlist-count"><%= hdrRsOwn("SONGS") %></span>
          </a>
        </li>
        <% hdrRsOwn.MoveNext : Loop %>
        <% If Not hdrHasOwn Then %>
        <li class="playlist-item empty">A&uacute;n no tienes playlists</li>
        <% End If %>
      </ul>
    </div>

    <% Do While Not hdrRsPub.EOF
         If Not hdrPubStarted Then
           hdrPubStarted = True %>
    <div class="sidebar-section">
      <div class="sidebar-head"><span>P&uacute;blicas</span></div>
      <ul class="playlist-list">
    <%   End If %>
        <li class="playlist-item">
          <a href="playlist.asp?id=<%= hdrRsPub("ID_PLAYLIST") %>">
            <img class="playlist-thumb" src="<%= H(MediaUrl(hdrRsPub("PHOTO"))) %>" alt="" loading="lazy" onerror="window.coverFail&&window.coverFail(this,'<%= J(Left(hdrRsPub("TITLE")&"",2)) %>')">
            <span class="playlist-name"><%= H(hdrRsPub("TITLE")) %></span>
            <span class="playlist-count"><%= hdrRsPub("SONGS") %></span>
          </a>
        </li>
    <%   hdrRsPub.MoveNext
       Loop
       If hdrPubStarted Then %>
      </ul>
    </div>
    <% End If %>
  </aside>
  <div class="content">
    <header class="topbar">
      <form class="search-box" action="search.asp" method="get" role="search">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" id="searchInput" name="q" value="<%= H(Request.QueryString("q")) %>" placeholder="Buscar canciones, artistas, &aacute;lbumes..." autocomplete="off">
      </form>
      <div class="user-chip">
        <img src="<%= H(MediaUrl(Session("userPhoto"))) %>" alt="" onerror="window.coverFail&&window.coverFail(this,'<%= J(Left(Session("username")&"",1)) %>')">
        <div class="user-info">
          <span class="user-name"><%= H(Session("username")) %></span>
          <span class="user-role <%= IIf(Session("userType")=1,"role-admin","role-user") %>"><%= H(Session("userTypeName")) %></span>
        </div>
        <a href="logout.asp" class="logout-btn" title="Cerrar sesi&oacute;n" aria-label="Cerrar sesi&oacute;n">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
        </a>
      </div>
    </header>
    <main class="main">
<%
hdrRsOwn.Close : Set hdrRsOwn = Nothing
hdrRsPub.Close : Set hdrRsPub = Nothing
hdrCn.Close : Set hdrCn = Nothing
%>
