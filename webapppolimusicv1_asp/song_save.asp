<%@ CODEPAGE=65001 LANGUAGE="VBScript" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/lib.asp"-->
<%
' ============================================================
'  song_save.asp  -  Inserta o actualiza una cancion (solo admin)
'  Trabaja con transaccion sobre TBL_SONG, TBL_TRACKLIST y TBL_PLAYER
' ============================================================
RequireAdmin()

If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
  Response.Redirect "songs.asp"
End If

Dim editId, sName, sPath, sPlays, sAlbumId, sArtists
editId   = ToInt(Request.Form("id"), 0)
sName    = SafeName(Request.Form("song_name"), 50)
sPath    = SafePath(Request.Form("song_path"), 255)
sPlays   = ToInt(Request.Form("plays"), 0)
sAlbumId = ToInt(Request.Form("album_id"), 0)
sArtists = Trim(Request.Form("artist_ids") & "")

If sName = "" Or sPath = "" Then
  Response.Redirect "song_form.asp?id=" & editId & "&err=datos"
End If

Dim cn, cmd, newId, rsNew
Set cn = Server.CreateObject("ADODB.Connection")
cn.Open ConnString()

cn.BeginTrans
On Error Resume Next

If editId > 0 Then
  ' ---------- ACTUALIZAR ----------
  Set cmd = NewCmd(cn, "UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ?, PLAYS = ? WHERE ID_SONG = ?")
  AddParam cmd, "n",  adVarChar, 50,  sName
  AddParam cmd, "p",  adVarChar, 255, sPath
  AddParam cmd, "pl", adInteger, 0,   sPlays
  AddParam cmd, "id", adInteger, 0,   editId
  cmd.Execute
  Set cmd = Nothing
  newId = editId
Else
  ' ---------- INSERTAR ----------
  ' OUTPUT INSERTED devuelve el ID generado en la misma sentencia
  ' (SCOPE_IDENTITY no sirve en un lote distinto al del INSERT)
  Set cmd = NewCmd(cn, "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) " & _
                       "OUTPUT INSERTED.ID_SONG VALUES (?, ?, ?)")
  AddParam cmd, "n",  adVarChar, 50,  sName
  AddParam cmd, "p",  adVarChar, 255, sPath
  AddParam cmd, "pl", adInteger, 0,   sPlays
  Set rsNew = cmd.Execute()
  If Not rsNew.EOF Then newId = CLng(rsNew(0)) Else newId = 0
  rsNew.Close : Set rsNew = Nothing
  Set cmd = Nothing
End If

If Err.Number <> 0 Or newId <= 0 Then
  cn.RollbackTrans
  Response.Redirect "songs.asp?err=" & Server.URLEncode("No se pudo guardar la cancion.")
End If

' ---------- RELACIONES ----------
' Elimina las relaciones anteriores de esta cancion
Set cmd = NewCmd(cn, "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?")
AddParam cmd, "id", adInteger, 0, newId
cmd.Execute
Set cmd = Nothing

Set cmd = NewCmd(cn, "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?")
AddParam cmd, "id", adInteger, 0, newId
cmd.Execute
Set cmd = Nothing

' Nuevo album (opcional)
If sAlbumId > 0 Then
  Set cmd = NewCmd(cn, "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (?, ?)")
  AddParam cmd, "a", adInteger, 0, sAlbumId
  AddParam cmd, "s", adInteger, 0, newId
  cmd.Execute
  Set cmd = Nothing
End If

' Nuevos artistas (opcional, varios)
If Len(sArtists) > 0 Then
  Dim arrArt, aId, i
  arrArt = Split(sArtists, ",")
  For i = 0 To UBound(arrArt)
    aId = ToInt(arrArt(i), 0)
    If aId > 0 Then
      Set cmd = NewCmd(cn, "INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) VALUES (?, ?)")
      AddParam cmd, "s", adInteger, 0, newId
      AddParam cmd, "a", adInteger, 0, aId
      cmd.Execute
      Set cmd = Nothing
    End If
  Next
End If

If Err.Number <> 0 Then
  cn.RollbackTrans
  Response.Redirect "songs.asp?err=" & Server.URLEncode("No se pudieron guardar los datos relacionados.")
Else
  cn.CommitTrans
  Response.Redirect "songs.asp?msg=guardado"
End If

cn.Close : Set cn = Nothing
%>
