<%
' ============================================================
'  config.asp  -  Parámetros de conexión y constantes
'  Base de datos: SQL Server (localhost) / BDD_PoliMusic
' ============================================================
Const DB_SERVER  = "localhost"
Const DB_NAME    = "BDD_PoliMusic"
Const DB_USER    = "usr_polimusic"
Const DB_PASS    = "Politecnica1"
Const APP_NAME   = "PoliMusic"

' ------------------------------------------------------------
'  Carpeta de imagenes y audios.
'  Se detecta automaticamente para que funcione en las dos
'  estructuras posibles:
'    1) recursos dentro de la app:  SongFilesAndImages_resources/
'    2) recursos un nivel arriba:   ../SongFilesAndImages_resources/
'  (estructura actual: la app esta en webapppolimusicv1_asp y
'   los recursos en la carpeta hermana)
' ------------------------------------------------------------
Dim MEDIA_ROOT
MEDIA_ROOT = DetectMediaRoot()

Function DetectMediaRoot()
  Dim fso, name, res
  name = "SongFilesAndImages_resources"
  res = name & "/"

  On Error Resume Next
  Set fso = Server.CreateObject("Scripting.FileSystemObject")
  If Err.Number = 0 Then
    If Not fso.FolderExists(Server.MapPath(name)) Then
      If fso.FolderExists(Server.MapPath("../" & name)) Then
        res = "../" & name & "/"
      End If
    End If
    Set fso = Nothing
  End If
  On Error GoTo 0

  DetectMediaRoot = res
End Function

Function ConnString()
  ' Proveedor OLE DB 18/19 (SQL Server 2019, 2022 y 2025).
  ' Si el servidor no lo tiene instalado, cambiar por:
  ' Provider=SQLOLEDB;...
  ConnString = "Provider=MSOLEDBSQL;Data Source=" & DB_SERVER & _
               ";Initial Catalog=" & DB_NAME & _
               ";User ID=" & DB_USER & ";Password=" & DB_PASS & _
               ";Encrypt=Optional;TrustServerCertificate=Yes;"
End Function
%>
