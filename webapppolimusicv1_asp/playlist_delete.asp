<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<%
' ============================================================
'  playlist_delete.asp  -  Elimina una playlist del usuario
' ============================================================
RequireLogin()

If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
  Response.Redirect "library.asp"
End If

Dim plId, uid
plId = ToInt(Request.Form("id"), 0)
uid  = CLng(Session("userId"))

If plId <= 0 Then
  Response.Redirect "library.asp"
End If

Dim cn, cmd, rs, exists
Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()
On Error Resume Next

' Solo el dueno puede eliminarla
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

cn.BeginTrans

Set cmd = NewCmd(cn, "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?")
AddParam cmd, "p", adInteger, 0, plId
cmd.Execute
Set cmd = Nothing

Set cmd = NewCmd(cn, "DELETE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?")
AddParam cmd, "p", adInteger, 0, plId
cmd.Execute
Set cmd = Nothing

If Err.Number <> 0 Then
  cn.RollbackTrans
  Response.Redirect "library.asp?err=" & Server.URLEncode("No se pudo eliminar la playlist.")
Else
  cn.CommitTrans
  Response.Redirect "library.asp?msg=playlist_eliminada"
End If

cn.Close : Set cn = Nothing
%>
