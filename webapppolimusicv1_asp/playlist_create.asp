<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<%
' ============================================================
'  playlist_create.asp  -  Crea una playlist del usuario
' ============================================================
RequireLogin()

If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
  Response.Redirect "library.asp"
End If

Dim plTitle, plType
plTitle = SafeName(Request.Form("title"), 50)
plType  = ToInt(Request.Form("type"), 0)
If plType <> 1 Then plType = 0

If plTitle = "" Then
  Response.Redirect "library.asp?err=" & Server.URLEncode("Escribe un nombre para la playlist.")
End If

Dim cn, cmd, rsNew, newId
Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()

On Error Resume Next

Set cmd = NewCmd(cn, "INSERT INTO TBL_PLAYLIST (ID_USER, TITLE, CREATION_DATE, TYPE) " & _
                     "OUTPUT INSERTED.ID_PLAYLIST VALUES (?, ?, GETDATE(), ?)")
AddParam cmd, "u", adInteger, 0, CLng(Session("userId"))
AddParam cmd, "t", adVarChar, 50, plTitle
AddParam cmd, "ty", adInteger, 0, plType
Set rsNew = cmd.Execute()
newId = 0
If Not rsNew.EOF Then newId = CLng(rsNew(0))
rsNew.Close : Set rsNew = Nothing
Set cmd = Nothing

If Err.Number <> 0 Or newId <= 0 Then
  Response.Redirect "library.asp?err=" & Server.URLEncode("No se pudo crear la playlist.")
End If

cn.Close : Set cn = Nothing
Response.Redirect "playlist.asp?id=" & newId & "&msg=playlist_creada"
%>
