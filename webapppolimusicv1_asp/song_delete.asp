<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<%
' ============================================================
'  song_delete.asp  -  Elimina una cancion y sus relaciones
'  Solo administrador, unicamente por POST
' ============================================================
RequireAdmin()

If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
  Response.Redirect "songs.asp"
End If

Dim delId
delId = ToInt(Request.Form("id"), 0)
If delId <= 0 Then
  Response.Redirect "songs.asp"
End If

Dim cn, cmd
Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()

cn.BeginTrans
On Error Resume Next

' Primero las tablas dependientes (por las claves foraneas)
Set cmd = NewCmd(cn, "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?")
AddParam cmd, "id", adInteger, 0, delId
cmd.Execute
Set cmd = Nothing

Set cmd = NewCmd(cn, "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?")
AddParam cmd, "id", adInteger, 0, delId
cmd.Execute
Set cmd = Nothing

Set cmd = NewCmd(cn, "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?")
AddParam cmd, "id", adInteger, 0, delId
cmd.Execute
Set cmd = Nothing

Set cmd = NewCmd(cn, "DELETE FROM TBL_SONG WHERE ID_SONG = ?")
AddParam cmd, "id", adInteger, 0, delId
cmd.Execute
Set cmd = Nothing

If Err.Number <> 0 Then
  cn.RollbackTrans
  Response.Redirect "songs.asp?err=" & Server.URLEncode("No se pudo eliminar la cancion.")
Else
  cn.CommitTrans
  Response.Redirect "songs.asp?msg=eliminado"
End If

cn.Close : Set cn = Nothing
%>
