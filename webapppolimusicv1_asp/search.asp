<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<!--#include file="includes/cards.asp"-->
<%
' ============================================================
'  search.asp  -  Busqueda de canciones por nombre, artista o album
' ============================================================
RequireLogin()

Dim pageTitle, activeNav
pageTitle = "Buscar"
activeNav = "search"

Dim q
q = Trim(Request.QueryString("q") & "")
' Se quitan los comodines para que el LIKE busque el texto tal cual
q = Replace(q, "%", "")
q = Replace(q, "_", "")
q = Replace(q, "[", "")

Dim cn, rs, cmd, rsCount, total, likeText, whereSql
Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()

total = 0

If q = "" Then
  Set rs = cn.Execute(SongSql(""))
  Set rsCount = cn.Execute("SELECT COUNT(*) AS T FROM TBL_SONG")
  If Not rsCount.EOF Then total = rsCount("T")
  rsCount.Close : Set rsCount = Nothing
Else
  likeText = "%" & q & "%"

  whereSql = "s.ID_SONG IN (" & _
             "SELECT s2.ID_SONG FROM TBL_SONG s2 WHERE s2.SONG_NAME LIKE ? " & _
             "UNION SELECT t.ID_SONG FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM a2 ON a2.ID_ALBUM = t.ID_ALBUM " & _
             "  WHERE a2.TITLE_ALBUM LIKE ? " & _
             "UNION SELECT p2.ID_SONG FROM TBL_PLAYER p2 INNER JOIN TBL_ARTIST ar2 ON ar2.ID_ARTIST = p2.ID_ARTIST " & _
             "  WHERE ar2.ARTIST_NAME LIKE ? OR ar2.ARTIST_LASTNAME LIKE ?)"

  Set cmd = NewCmd(cn, "SELECT COUNT(*) AS T FROM TBL_SONG s WHERE " & whereSql)
  AddParam cmd, "q1", adVarChar, 120, likeText
  AddParam cmd, "q2", adVarChar, 120, likeText
  AddParam cmd, "q3", adVarChar, 120, likeText
  AddParam cmd, "q4", adVarChar, 120, likeText
  Set rsCount = cmd.Execute()
  If Not rsCount.EOF Then total = rsCount("T")
  rsCount.Close : Set rsCount = Nothing
  Set cmd = Nothing

  Set cmd = NewCmd(cn, SongSql(whereSql))
  AddParam cmd, "q1", adVarChar, 120, likeText
  AddParam cmd, "q2", adVarChar, 120, likeText
  AddParam cmd, "q3", adVarChar, 120, likeText
  AddParam cmd, "q4", adVarChar, 120, likeText
  Set rs = cmd.Execute()
  Set cmd = Nothing
End If
%>
<!--#include file="includes/header.asp"-->

<section class="section">
  <div class="section-head">
    <h2>Buscar</h2>
    <p class="section-desc">
      <% If q = "" Then %>
        Escribe en el buscador de arriba o explora todas las canciones disponibles.
      <% Else %>
        Resultados para &laquo;<strong><%= H(q) %></strong>&raquo; &bull; <%= total & " " & IIf(total = 1, "canci&oacute;n encontrada", "canciones encontradas") %>
      <% End If %>
    </p>
  </div>

  <% If q = "" Then %>
  <div class="chips">
    <span class="chip active">Todas las canciones</span>
  </div>
  <% End If %>

  <div class="song-grid" id="songGrid">
    <% RenderSongGrid rs %>
    <div class="empty-state" id="emptyState"<% If total > 0 Then %> style="display:none"<% End If %>>
      <% If q = "" Then %>
        Todav&iacute;a no hay canciones registradas.
      <% Else %>
        No se encontraron canciones para &laquo;<%= H(q) %>&raquo;. Prueba con otro nombre, artista o &aacute;lbum.
      <% End If %>
    </div>
  </div>
</section>

<%
rs.Close : Set rs = Nothing
cn.Close : Set cn = Nothing
%>

<!--#include file="includes/footer.asp"-->
