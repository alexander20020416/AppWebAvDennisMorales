    </main>
  </div>
</div>

<!-- ===================== REPRODUCTOR ===================== -->
<div class="player" id="player">
  <div class="player-left">
    <img id="playerCover" alt="" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" onerror="window.coverFail&&window.coverFail(this,'')">
    <div class="player-meta">
      <div id="playerTitle" class="player-title">Selecciona una canci&oacute;n</div>
      <div id="playerArtist" class="player-artist">&mdash;</div>
    </div>
  </div>
  <div class="player-center">
    <div class="player-btns">
      <button id="btnShuffle" class="player-btn small" title="Aleatorio" aria-label="Aleatorio">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 3 21 3 21 8"/><polyline points="4 20 9 20 21 8"/><polyline points="21 3 16 8 16 3"/><polyline points="9 20 4 15 9 15"/></svg>
      </button>
      <button id="btnPrev" class="player-btn" title="Anterior" aria-label="Anterior">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/></svg>
      </button>
      <button id="btnPlay" class="player-btn play" title="Reproducir / Pausa" aria-label="Reproducir o pausar">
        <svg id="iconPlay" width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
        <svg id="iconPause" width="24" height="24" viewBox="0 0 24 24" fill="currentColor" style="display:none"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>
      </button>
      <button id="btnNext" class="player-btn" title="Siguiente" aria-label="Siguiente">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/></svg>
      </button>
      <button id="btnRepeat" class="player-btn small" title="Repetir" aria-label="Repetir">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>
      </button>
    </div>
    <div class="progress-wrap">
      <span id="curTime">0:00</span>
      <div class="progress-bar" id="progressBar" role="slider" aria-label="Progreso de la canci&oacute;n">
        <div class="progress-fill" id="progressFill"></div>
        <div class="progress-thumb" id="progressThumb"></div>
      </div>
      <span id="totTime">0:00</span>
    </div>
  </div>
  <div class="player-right">
    <button id="btnMute" class="player-btn small" aria-label="Silenciar">
      <svg id="iconVol" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/></svg>
      <svg id="iconMute" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display:none"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><line x1="23" y1="9" x2="17" y2="15"/><line x1="17" y1="9" x2="23" y2="15"/></svg>
    </button>
    <div class="volume-bar" id="volumeBar" role="slider" aria-label="Volumen"><div class="volume-fill" id="volumeFill"></div></div>
  </div>
</div>

<!-- ===================== MODAL ELIMINAR ===================== -->
<div class="modal" id="confirmModal" aria-hidden="true">
  <div class="modal-box">
    <h3>&iquest;Eliminar canci&oacute;n?</h3>
    <p id="modalText">Esta acci&oacute;n no se puede deshacer.</p>
    <div class="modal-actions">
      <button class="btn btn-ghost" onclick="closeModal()">Cancelar</button>
      <form method="post" action="song_delete.asp" id="modalForm" style="display:inline">
        <input type="hidden" name="id" id="modalId">
        <button type="submit" class="btn btn-danger">Eliminar</button>
      </form>
    </div>
  </div>
</div>

<!-- ===================== MODAL AGREGAR A PLAYLIST ===================== -->
<div class="modal" id="playlistModal" aria-hidden="true">
  <div class="modal-box">
    <h3>Agregar a playlist</h3>
    <p id="playlistModalText">Elige una playlist o crea una nueva.</p>
    <form method="post" action="playlist_song.asp" id="playlistForm">
      <input type="hidden" name="song_id" id="playlistSongId">
      <% If Trim(plOptions & "") <> "" Then %>
      <label class="modal-field">
        <span>Playlists existentes</span>
        <select name="playlist_id" id="playlistSelect">
          <option value="">&mdash; Selecciona una &mdash;</option>
          <%= plOptions %>
        </select>
      </label>
      <% End If %>
      <label class="modal-field">
        <span>O crea una nueva</span>
        <input type="text" name="new_title" maxlength="50" placeholder="Nombre de la playlist">
      </label>
      <div class="modal-actions">
        <button type="button" class="btn btn-ghost" onclick="closePlaylistModal()">Cancelar</button>
        <button type="submit" class="btn btn-primary">Agregar</button>
      </div>
    </form>
  </div>
</div>

<div class="toast" id="toast" aria-live="polite"></div>

<script src="js/app.js"></script>
</body>
</html>
