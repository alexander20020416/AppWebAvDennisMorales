<%
' ============================================================
'  lib.asp  -  Utilidades, seguridad de sesión y helpers
' ============================================================

Response.Charset = "utf-8"
Session.CodePage = 65001

' Constantes ADO necesarias
Const adParamInput  = 1
Const adVarChar     = 200
Const adInteger     = 3
Const adDBTimeStamp = 135

' ------------------------------------------------------------
' IIf no existe en VBScript (solo en VBA). Se implementa aqui
' para poder usar la forma IIf(condicion, si, no).
' ------------------------------------------------------------
Function IIf(cond, valorSi, valorNo)
  If cond Then
    IIf = valorSi
  Else
    IIf = valorNo
  End If
End Function

' ------------------------------------------------------------
' Escapa texto para insertarlo en HTML
' ------------------------------------------------------------
Function H(v)
  Dim s
  s = Trim(v & "")
  s = Replace(s, "&", "&amp;")
  s = Replace(s, "<", "&lt;")
  s = Replace(s, ">", "&gt;")
  s = Replace(s, """", "&quot;")
  s = Replace(s, "'", "&#39;")
  H = s
End Function

' ------------------------------------------------------------
' Escapa texto para insertarlo dentro de JavaScript
' ------------------------------------------------------------
Function J(v)
  Dim s, bs
  bs = Chr(92)   ' barra invertida
  s = Trim(v & "")
  s = Replace(s, bs, bs & bs)
  s = Replace(s, """", bs & """")
  s = Replace(s, "'", bs & "'")
  s = Replace(s, vbCr, bs & "r")
  s = Replace(s, vbLf, bs & "n")
  s = Replace(s, "</", "<" & bs & "/")
  J = s
End Function

' ------------------------------------------------------------
' Convierte rutas de la BD (~/songFiles/x.mp3) en rutas web
' ------------------------------------------------------------
Function MediaUrl(p)
  Dim s
  s = Trim(p & "")
  If s = "" Then
    MediaUrl = ""
    Exit Function
  End If
  s = Replace(s, "\", "/")
  If Left(s, 2) = "~/" Then s = Mid(s, 3)
  MediaUrl = MEDIA_ROOT & s
End Function

' ------------------------------------------------------------
' Agrega un parametro a un ADODB.Command
' ------------------------------------------------------------
Sub AddParam(cmd, name, dtype, size, value)
  cmd.Parameters.Append cmd.CreateParameter(name, dtype, adParamInput, size, value)
End Sub

' ------------------------------------------------------------
' Crea un Command nuevo. Reutilizar el mismo objeto Command con
' otra sentencia hace que SQL Server devuelva errores de OLE DB,
' por eso cada sentencia usa su propio Command.
' ------------------------------------------------------------
Function NewCmd(cn, sql)
  Dim c
  Set c = Server.CreateObject("ADODB.Command")
  c.ActiveConnection = cn
  c.CommandType = 1
  c.CommandText = sql
  Set NewCmd = c
End Function

' ------------------------------------------------------------
' Seguridad: exige sesión iniciada
' ------------------------------------------------------------
Sub RequireLogin()
  If IsEmpty(Session("userId")) Or Session("userId") = "" Then
    Response.Redirect "login.asp?expired=1"
  End If
End Sub

' ------------------------------------------------------------
' Seguridad: exige rol administrador (USER_TYPE = 1)
' ------------------------------------------------------------
Sub RequireAdmin()
  RequireLogin()
  If CInt(Session("userType")) <> 1 Then
    Response.Redirect "songs.asp?err=access"
  End If
End Sub

' ------------------------------------------------------------
' Conversión segura a entero
' ------------------------------------------------------------
Function ToInt(v, def)
  On Error Resume Next
  Dim n
  n = CInt(v)
  If Err.Number <> 0 Then n = def
  On Error GoTo 0
  ToInt = n
End Function

' ------------------------------------------------------------
' Limpia y recorta cadenas con longitud máxima
' ------------------------------------------------------------
Function SafeName(v, maxLen)
  Dim s
  s = Trim(v & "")
  If Len(s) > maxLen Then s = Left(s, maxLen)
  SafeName = s
End Function

Function SafePath(v, maxLen)
  Dim s
  s = Trim(v & "")
  If Len(s) > maxLen Then s = Left(s, maxLen)
  SafePath = s
End Function
%>
