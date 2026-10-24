<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<%
' ============================================================
'  login.asp  -  Autenticación contra TBL_USER
'  Soporta contraseña en texto plano y contraseña SHA1
' ============================================================
Dim msg, errMsg
msg = Trim(Request.QueryString("msg") & "")
errMsg = ""

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
  Dim u, p, cn, rs, cmdAuth
  u = SafeName(Request.Form("username"), 50)
  p = SafeName(Request.Form("password"), 50)

  If u = "" Or p = "" Then
    errMsg = "Ingresa usuario y contrase&ntilde;a."
  Else
    Set cn = Server.CreateObject("ADODB.Connection")
    cn.Open ConnString()

    Set cmdAuth = Server.CreateObject("ADODB.Command")
    cmdAuth.ActiveConnection = cn
    cmdAuth.CommandType = 1
    cmdAuth.CommandText = "SELECT u.*, c.VALUE AS USER_TYPE_NAME " & _
                          "FROM TBL_USER u " & _
                          "LEFT JOIN TBL_CATALOG c ON c.COD_CATALOG = CAST(u.USER_TYPE AS VARCHAR(8)) AND c.COD_CATALOG_PARENT = '1' " & _
                          "WHERE u.USERNAME = ? AND (u.PASSWORD = ? OR u.PASSWORD = UPPER(CONVERT(VARCHAR(40), HASHBYTES('SHA1', ?), 2)))"
    AddParam cmdAuth, "@u", adVarChar, 50, u
    AddParam cmdAuth, "@p", adVarChar, 50, p
    AddParam cmdAuth, "@ph", adVarChar, 50, p

    Set rs = cmdAuth.Execute()
    If Not rs.EOF Then
      Session("userId")       = rs("ID_USER")
      Session("username")     = rs("USERNAME")
      Session("userType")     = rs("USER_TYPE")
      Session("userTypeName") = rs("USER_TYPE_NAME")
      Session("userPhoto")    = rs("USER_PHOTO")
      Session("email")        = rs("EMAIL")
      Response.Redirect "songs.asp"
    Else
      errMsg = "Usuario o contrase&ntilde;a incorrectos."
    End If

    rs.Close : Set rs = Nothing
    Set cmdAuth = Nothing
    cn.Close : Set cn = Nothing
  End If
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Iniciar sesi&oacute;n &mdash; <%= H(APP_NAME) %></title>
<link rel="stylesheet" href="css/styles.css">
</head>
<body class="page-login">
<div class="login-wrap">

  <div class="login-brand">
    <div class="brand-blobs" aria-hidden="true">
      <div class="blob blob1"></div>
      <div class="blob blob2"></div>
      <div class="blob blob3"></div>
    </div>
    <div class="brand-content">
      <div class="brand-icon">
        <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><path d="M12 8v8"/><path d="M8 12l4 4 4-4"/></svg>
      </div>
      <h1 class="brand-title"><%= H(APP_NAME) %></h1>
      <p class="brand-sub">Tu m&uacute;sica, tu estilo.</p>
    </div>
  </div>

  <div class="login-card">
    <h2>Iniciar sesi&oacute;n</h2>
    <p class="login-sub">Accede para escuchar tu m&uacute;sica.</p>

    <% If errMsg <> "" Then %>
    <div class="alert alert-error"><%= errMsg %></div>
    <% End If %>
    <% If msg = "logout" Then %>
    <div class="alert alert-success">Sesi&oacute;n cerrada correctamente.</div>
    <% End If %>
    <% If Request.QueryString("expired") = "1" Then %>
    <div class="alert alert-info">La sesi&oacute;n expir&oacute;. Vuelve a iniciar sesi&oacute;n.</div>
    <% End If %>

    <form method="post" action="login.asp" class="login-form">
      <label>
        <span>Usuario</span>
        <input type="text" name="username" placeholder="usuario" maxlength="50" required autofocus>
      </label>
      <label>
        <span>Contrase&ntilde;a</span>
        <input type="password" name="password" placeholder="********" maxlength="50" required>
      </label>
      <button type="submit" class="btn btn-primary btn-block">Ingresar</button>
    </form>

    <div class="login-demo">
      <p><strong>Usuarios de prueba</strong></p>
      <ul>
        <li><code>userAdmin</code> / <code>12345678</code> <span class="badge-admin">Admin</span></li>
        <li><code>userNormal</code> / <code>12345678</code> <span class="badge-user">Usuario</span></li>
        <li><code>username1</code> / <code>12345678</code> <span class="badge-user">Usuario</span></li>
      </ul>
    </div>
  </div>

</div>
</body>
</html>
