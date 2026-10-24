<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<%
' ============================================================
'  playlist_song.asp  -  Agrega o quita una cancion de una playlist
'  action = add | remove
' ============================================================
RequireLogin()

If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
  Response.Redirect "library.asp"
End If

Dim action, songId, plId, newTitle, uid
action  = LCase(Trim(Request.Form("action") & ""))
songId  = ToInt(Request.Form("song_id"), 0)
plId    = ToInt(Request.Form("playlist_id"), 0)
newTitle = SafeName(Request.Form("new_title"), 50)
uid     = CLng(Session("userId"))

If action = "" Then action = "add"
If songId <= 0 Then
  Response.Redirect "library.asp?err=" & Server.URLEncode("Cancion no valida.")
End If

Dim cn, cmd, rs, newId, exists
Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()
On Error Resume Next

' ------------------------------------------------------------
'  Si escribio un nombre nuevo, se crea la playlist primero
' ------------------------------------------------------------
If action = "add" And newTitle <> "" Then
  Set cmd = NewCmd(cn, "INSERT INTO TBL_PLAYLIST (ID_USER, TITLE, CREATION_DATE, TYPE) " & _
                       "OUTPUT INSERTED.ID_PLAYLIST VALUES (?, ?, GETDATE(), 0)")
  AddParam cmd, "u", adInteger, 0, uid
  AddParam cmd, "t", adVarChar, 50, newTitle
  Set rs = cmd.Execute()
  If Not rs.EOF Then plId = CLng(rs(0))
  rs.Close : Set rs = Nothing
  Set cmd = Nothing
  If Err.Number <> 0 Then
    Response.Redirect "songs.asp?err=" & Server.URLEncode("No se pudo crear la playlist.")
  End If
End If

If plId <= 0 Then
  Response.Redirect "songs.asp?err=" & Server.URLEncode("Selecciona una playlist.")
End If

' ------------------------------------------------------------
'  Verifica que la playlist sea del usuario
' ------------------------------------------------------------
Set cmd = NewCmd(cn, "SELECT COUNT(*) AS T FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ? AND ID_USER = ?")
AddParam cmd, "p", adInteger, 0, plId
AddParam cmd, "u", adInteger, 0, uid
Set rs = cmd.Execute()
exists = 0
If Not rs.EOF Then exists = rs("T")
rs.Close : Set rs = Nothing
Set cmd = Nothing

If exists = 0 Then
  cn.Close : Set cn = Nothing
  Response.Redirect "library.asp?err=" & Server.URLEncode("Esa playlist no es tuya.")
End If

If action = "remove" Then
  ' ----------------------------------------------------------
  '  Quitar
  ' ----------------------------------------------------------
  Set cmd = NewCmd(cn, "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?")
  AddParam cmd, "p", adInteger, 0, plId
  AddParam cmd, "s", adInteger, 0, songId
  cmd.Execute
  Set cmd = Nothing

  cn.Close : Set cn = Nothing
  Response.Redirect "playlist.asp?id=" & plId & "&msg=quitado"
Else
  ' ----------------------------------------------------------
  '  Agregar (sin duplicados)
  ' ----------------------------------------------------------
  Set cmd = NewCmd(cn, "SELECT COUNT(*) AS T FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?")
  AddParam cmd, "p", adInteger, 0, plId
  AddParam cmd, "s", adInteger, 0, songId
  Set rs = cmd.Execute()
  exists = 0
  If Not rs.EOF Then exists = rs("T")
  rs.Close : Set rs = Nothing
  Set cmd = Nothing

  If exists > 0 Then
    cn.Close : Set cn = Nothing
    Response.Redirect "playlist.asp?id=" & plId & "&msg=ya_existe"
  End If

  Set cmd = NewCmd(cn, "INSERT INTO TBL_PLAYLIST_SONG (ID_PLAYLIST, ID_SONG) VALUES (?, ?)")
  AddParam cmd, "p", adInteger, 0, plId
  AddParam cmd, "s", adInteger, 0, songId
  cmd.Execute
  Set cmd = Nothing

  cn.Close : Set cn = Nothing
  Response.Redirect "playlist.asp?id=" & plId & "&msg=agregado"
End If
%>
