<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<%
' ============================================================
'  song_play.asp  -  Incrementa el contador de reproducciones
'  Llamado por app.js mediante fetch (POST)
' ============================================================
If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
  Response.Status = "405 Method Not Allowed"
  Response.End
End If

Dim pid
pid = ToInt(Request.Form("id"), 0)
If pid <= 0 Then
  Response.Status = "400 Bad Request"
  Response.End
End If

Dim cn
Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()
cn.Execute "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS,0) + 1 WHERE ID_SONG = " & pid
cn.Close : Set cn = Nothing

Response.ContentType = "application/json"
Response.Write "{ ""ok"": true }"
%>
