<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<%
' ============================================================
'  default.asp  -  Página de entrada
' ============================================================
If IsEmpty(Session("userId")) Or Session("userId") = "" Then
  Response.Redirect "login.asp"
Else
  Response.Redirect "songs.asp"
End If
%>
