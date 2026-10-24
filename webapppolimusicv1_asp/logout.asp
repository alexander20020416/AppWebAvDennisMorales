<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<%
' ============================================================
'  logout.asp  -  Cierre de sesión
' ============================================================
Session.Abandon()
Response.Redirect "login.asp?msg=logout"
%>
