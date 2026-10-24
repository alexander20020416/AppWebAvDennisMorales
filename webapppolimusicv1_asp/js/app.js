/* ============================================================
   app.js — PoliMusic
   Reproductor, búsqueda, orden, modal de eliminación y avisos
   ============================================================ */
(function () {
  'use strict';

  const $ = function (id) { return document.getElementById(id); };
  const audio = new Audio();
  let playlist = [];
  let currentIdx = -1;
  let repeatMode = 0;      // 0 = no, 1 = todo, 2 = una
  let shuffleOn = false;
  let lastVol = 0.8;
  audio.volume = lastVol;

  /* ---------------------------------------------------------
     Lista de reproducción construida desde las tarjetas
     --------------------------------------------------------- */
  function buildPlaylist() {
    const cards = Array.prototype.slice.call(document.querySelectorAll('.song-card'));
    playlist = cards.map(function (c) {
      return {
        id: c.dataset.id,
        title: c.dataset.title,
        src: c.dataset.src,
        cover: c.dataset.cover,
        artist: c.dataset.artist,
        plays: parseInt(c.dataset.plays || '0', 10),
        el: c
      };
    });
  }

  /* ---------------------------------------------------------
     Portadas de respaldo (cuando el archivo no existe)
     --------------------------------------------------------- */
  window.coverFail = function (img, label) {
    if (img.dataset.fallback) return;
    img.dataset.fallback = '1';
    const l = (label || '\u266A').toString();
    const code = l.charCodeAt(0) || 0;
    const hue = ((code * 37) + (l.length > 1 ? l.charCodeAt(1) * 13 : 0)) % 360;
    const hue2 = (hue + 40) % 360;
    const svg = '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="400">' +
      '<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">' +
      '<stop offset="0%" stop-color="hsl(' + hue + ',80%,58%)"/>' +
      '<stop offset="100%" stop-color="hsl(' + hue2 + ',70%,44%)"/></linearGradient></defs>' +
      '<rect width="400" height="400" fill="url(#g)"/>' +
      '<text x="200" y="260" font-size="160" fill="rgba(255,255,255,.92)" text-anchor="middle" ' +
      'font-family="-apple-system,Segoe UI,sans-serif" font-weight="700">' +
      escapeXml(l) + '</text></svg>';
    img.src = 'data:image/svg+xml;base64,' + btoa(svg);
  };

  function escapeXml(s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  /* ---------------------------------------------------------
     Reproductor
     --------------------------------------------------------- */
  function formatTime(sec) {
    if (!isFinite(sec) || sec < 0) return '0:00';
    const m = Math.floor(sec / 60);
    const s = Math.floor(sec % 60);
    return m + ':' + (s < 10 ? '0' : '') + s;
  }

  function setCover(src, label) {
    const img = $('playerCover');
    img.dataset.fallback = '';
    img.onerror = function () { window.coverFail(this, label || '\u266A'); };
    img.src = src || '';
  }

  function loadTrack(i) {
    if (!playlist.length) return;
    currentIdx = ((i % playlist.length) + playlist.length) % playlist.length;
    const t = playlist[currentIdx];
    audio.src = t.src;
    $('playerTitle').textContent = t.title;
    $('playerArtist').textContent = t.artist || '—';
    setCover(t.cover, t.title ? t.title.charAt(0) : '\u266A');
    $('totTime').textContent = '0:00';
    $('progressFill').style.width = '0%';
    $('progressThumb').style.left = '0%';
    play();
  }

  function play() {
    const p = audio.play();
    if (p && p.catch) p.catch(function () { /* archivo ausente o bloqueado */ });
    $('iconPlay').style.display = 'none';
    $('iconPause').style.display = '';
    highlightCard(currentIdx);
  }

  function pause() {
    audio.pause();
    $('iconPlay').style.display = '';
    $('iconPause').style.display = 'none';
  }

  function togglePlay() {
    if (currentIdx < 0) {
      if (playlist.length) loadTrack(0);
    } else if (audio.paused) {
      play();
    } else {
      pause();
    }
  }

  function next() {
    if (!playlist.length) return;
    if (shuffleOn) { loadTrack(Math.floor(Math.random() * playlist.length)); return; }
    if (currentIdx + 1 < playlist.length) loadTrack(currentIdx + 1);
    else if (repeatMode === 1) loadTrack(0);
    else { pause(); currentIdx = -1; highlightCard(-1); }
  }

  function prev() {
    if (!playlist.length) return;
    if (audio.currentTime > 3) { audio.currentTime = 0; return; }
    if (currentIdx > 0) loadTrack(currentIdx - 1);
    else if (repeatMode === 1) loadTrack(playlist.length - 1);
  }

  function highlightCard(idx) {
    playlist.forEach(function (t, i) {
      if (t.el) t.el.classList.toggle('now-playing', i === idx);
    });
  }

  function reportPlay(id) {
    if (!id) return;
    fetch('song_play.asp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'id=' + encodeURIComponent(id)
    }).then(function () {
      /* Refresca el contador visible de la tarjeta */
      const card = document.querySelector('.song-card[data-id="' + id + '"]');
      if (!card) return;
      const n = (parseInt(card.dataset.plays, 10) || 0) + 1;
      card.dataset.plays = n;
      const badge = card.querySelector('.card-plays');
      if (badge) badge.innerHTML = badge.innerHTML.replace(/\d+\s*$/, n);
    }).catch(function () { /* silencioso */ });
  }

  /* ---------------------------------------------------------
     Barra de progreso y volumen
     --------------------------------------------------------- */
  function seek(bar, fill, thumb, ev, cb) {
    const rect = bar.getBoundingClientRect();
    let ratio = (ev.clientX - rect.left) / rect.width;
    ratio = Math.max(0, Math.min(1, ratio));
    fill.style.width = (ratio * 100) + '%';
    if (thumb) thumb.style.left = (ratio * 100) + '%';
    cb(ratio);
  }

  $('progressBar').addEventListener('click', function (e) {
    seek($('progressBar'), $('progressFill'), $('progressThumb'), e, function (r) {
      if (audio.duration) audio.currentTime = r * audio.duration;
    });
  });

  $('volumeBar').addEventListener('click', function (e) {
    seek($('volumeBar'), $('volumeFill'), null, e, function (r) {
      audio.volume = r;
      audio.muted = false;
      lastVol = r;
      updateMuteIcon();
    });
  });

  let reportedId = null;
  audio.addEventListener('timeupdate', function () {
    if (!audio.duration) return;
    const ratio = audio.currentTime / audio.duration;
    $('progressFill').style.width = (ratio * 100) + '%';
    $('progressThumb').style.left = (ratio * 100) + '%';
    $('curTime').textContent = formatTime(audio.currentTime);

    /* La reproduccion se cuenta solo tras 5 s reales de escucha */
    const t = playlist[currentIdx];
    if (t && audio.currentTime >= 5 && reportedId !== t.id) {
      reportedId = t.id;
      reportPlay(t.id);
    }
  });

  audio.addEventListener('loadedmetadata', function () {
    $('totTime').textContent = formatTime(audio.duration);
  });

  audio.addEventListener('ended', function () {
    if (repeatMode === 2) { audio.currentTime = 0; play(); }
    else next();
  });

  /* Aviso claro cuando el MP3 no existe en la carpeta de recursos */
  let lastErrSrc = '';
  audio.addEventListener('error', function () {
    const t = playlist[currentIdx];
    const src = (t && t.src) || '';
    if (!src || src === lastErrSrc) return;
    lastErrSrc = src;
    $('iconPlay').style.display = '';
    $('iconPause').style.display = 'none';
    showToast('No se encontró el audio "' + src.split('/').pop() + '". Cópialo en SongFilesAndImages_resources/SongFiles/.', 'err');
  });

  function updateMuteIcon() {
    const muted = audio.muted || audio.volume === 0;
    $('iconVol').style.display = muted ? 'none' : '';
    $('iconMute').style.display = muted ? '' : 'none';
  }

  $('btnMute').addEventListener('click', function () {
    if (audio.muted || audio.volume === 0) {
      audio.muted = false;
      audio.volume = lastVol || 0.8;
    } else {
      lastVol = audio.volume;
      audio.volume = 0;
      audio.muted = true;
    }
    updateMuteIcon();
    $('volumeFill').style.width = (audio.volume * 100) + '%';
  });

  $('volumeFill').style.width = (audio.volume * 100) + '%';

  /* ---------------------------------------------------------
     Botones del reproductor
     --------------------------------------------------------- */
  $('btnPlay').addEventListener('click', togglePlay);
  $('btnNext').addEventListener('click', next);
  $('btnPrev').addEventListener('click', prev);

  $('btnShuffle').addEventListener('click', function () {
    shuffleOn = !shuffleOn;
    this.classList.toggle('active', shuffleOn);
  });

  $('btnRepeat').addEventListener('click', function () {
    repeatMode = (repeatMode + 1) % 3;
    this.classList.toggle('active', repeatMode !== 0);
    this.title = ['Repetir', 'Repetir todo', 'Repetir una'][repeatMode];
  });

  /* ---------------------------------------------------------
     Clic en una tarjeta
     --------------------------------------------------------- */
  document.addEventListener('click', function (e) {
    const card = e.target.closest('.song-card');
    if (!card) return;
    const isPlay = e.target.closest('.card-play');
    if (!isPlay && e.target.closest('a,button')) return;
    const idx = playlist.findIndex(function (t) { return t.id === card.dataset.id; });
    if (idx >= 0) loadTrack(idx);
  });

  /* ---------------------------------------------------------
     Búsqueda en vivo
     --------------------------------------------------------- */
  const searchInput = $('searchInput');
  if (searchInput) {
    searchInput.addEventListener('input', function () {
      const q = searchInput.value.trim().toLowerCase();
      let visible = 0;
      document.querySelectorAll('.song-card').forEach(function (c) {
        const album = c.querySelector('.card-album');
        const text = (c.dataset.title + ' ' + c.dataset.artist + ' ' + (album ? album.textContent : '')).toLowerCase();
        const match = text.indexOf(q) !== -1;
        c.style.display = match ? '' : 'none';
        if (match) visible++;
      });
      const empty = document.getElementById('emptyState');
      if (empty) empty.style.display = visible ? 'none' : '';
    });
  }

  /* ---------------------------------------------------------
     Orden: Todos / Más escuchadas / A-Z
     --------------------------------------------------------- */
  const chips = document.getElementById('sortChips');
  if (chips) {
    chips.addEventListener('click', function (e) {
      const chip = e.target.closest('.chip');
      if (!chip) return;
      chips.querySelectorAll('.chip').forEach(function (c) { c.classList.remove('active'); });
      chip.classList.add('active');
      const mode = chip.dataset.sort;
      const grid = document.getElementById('songGrid');
      const cards = Array.prototype.slice.call(grid.querySelectorAll('.song-card'));
      cards.sort(function (a, b) {
        if (mode === 'plays') return parseInt(b.dataset.plays || '0', 10) - parseInt(a.dataset.plays || '0', 10);
        if (mode === 'az') return (a.dataset.title || '').localeCompare(b.dataset.title || '');
        return parseInt(a.dataset.id || '0', 10) - parseInt(b.dataset.id || '0', 10);
      });
      cards.forEach(function (c) { grid.appendChild(c); });
      const empty = document.getElementById('emptyState');
      if (empty) grid.appendChild(empty);
      buildPlaylist();
    });
  }

  /* ---------------------------------------------------------
     Modal de eliminación
     --------------------------------------------------------- */
  window.openDelete = function (btn) {
    $('modalId').value = btn.dataset.id;
    $('modalText').textContent = 'Se eliminará "' + (btn.dataset.name || '') + '" permanentemente.';
    $('confirmModal').setAttribute('aria-hidden', 'false');
  };
  window.closeModal = function () {
    $('confirmModal').setAttribute('aria-hidden', 'true');
  };
  $('confirmModal').addEventListener('click', function (e) {
    if (e.target === $('confirmModal')) window.closeModal();
  });

  /* ---------------------------------------------------------
     Modal "Agregar a playlist"
     --------------------------------------------------------- */
  window.openPlaylistModal = function (btn) {
    const m = $('playlistModal');
    if (!m) return;
    $('playlistSongId').value = btn.dataset.id;
    $('playlistModalText').textContent = 'Agregar "' + (btn.dataset.name || '') + '" a una playlist.';
    m.setAttribute('aria-hidden', 'false');
  };
  window.closePlaylistModal = function () {
    const m = $('playlistModal');
    if (m) m.setAttribute('aria-hidden', 'true');
  };
  const plModal = $('playlistModal');
  if (plModal) {
    plModal.addEventListener('click', function (e) {
      if (e.target === plModal) window.closePlaylistModal();
    });
  }

  /* ---------------------------------------------------------
     Botón "Reproducir" de una playlist
     --------------------------------------------------------- */
  const playAllBtn = $('playAllBtn');
  if (playAllBtn) {
    playAllBtn.addEventListener('click', function () {
      const first = document.querySelector('.song-card .card-play');
      if (first) first.click();
    });
  }

  /* ---------------------------------------------------------
     Atajos de teclado
     --------------------------------------------------------- */
  document.addEventListener('keydown', function (e) {
    const tag = (document.activeElement && document.activeElement.tagName || '').toLowerCase();
    const editing = tag === 'input' || tag === 'textarea' || tag === 'select';
    if (editing) return;
    if (e.code === 'Space') { e.preventDefault(); togglePlay(); }
    if (e.code === 'ArrowRight') { audio.currentTime = Math.min(audio.duration || 0, audio.currentTime + 10); }
    if (e.code === 'ArrowLeft') { audio.currentTime = Math.max(0, audio.currentTime - 10); }
    if (e.code === 'ArrowUp') {
      e.preventDefault();
      audio.volume = Math.min(1, audio.volume + 0.05);
      $('volumeFill').style.width = (audio.volume * 100) + '%';
    }
    if (e.code === 'ArrowDown') {
      e.preventDefault();
      audio.volume = Math.max(0, audio.volume - 0.05);
      $('volumeFill').style.width = (audio.volume * 100) + '%';
    }
  });

  /* ---------------------------------------------------------
     Avisos (toast)
     --------------------------------------------------------- */
  function showToast(msg, type) {
    const t = $('toast');
    if (!t) return;
    t.textContent = msg;
    t.style.background = type === 'err' ? 'rgba(255,77,109,0.18)'
      : (type === 'ok' ? 'rgba(61,220,132,0.12)' : 'var(--surface)');
    t.style.borderColor = type === 'err' ? 'rgba(255,77,109,0.35)'
      : (type === 'ok' ? 'rgba(61,220,132,0.28)' : 'var(--border)');
    t.classList.add('show');
    setTimeout(function () { t.classList.remove('show'); }, 3200);
  }

  const qs = new URLSearchParams(location.search);
  if (qs.get('msg') === 'guardado') showToast('Canción guardada correctamente.', 'ok');
  if (qs.get('msg') === 'eliminado') showToast('Canción eliminada.', 'ok');
  if (qs.get('msg') === 'playlist_creada') showToast('Playlist creada. Ya puedes agregarle canciones.', 'ok');
  if (qs.get('msg') === 'agregado') showToast('Canción agregada a la playlist.', 'ok');
  if (qs.get('msg') === 'ya_existe') showToast('Esa canción ya está en la playlist.', 'err');
  if (qs.get('msg') === 'quitado') showToast('Canción quitada de la playlist.', 'ok');
  if (qs.get('msg') === 'playlist_eliminada') showToast('Playlist eliminada.', 'ok');
  if (qs.get('err') === 'access') showToast('No tienes permisos para realizar esa acción.', 'err');
  if (qs.get('err') && qs.get('err') !== 'access') showToast(qs.get('err'), 'err');

  /* ---------------------------------------------------------
     Inicialización
     --------------------------------------------------------- */
  buildPlaylist();
  if (playlist.length) {
    const t = playlist[0];
    $('playerTitle').textContent = t.title;
    $('playerArtist').textContent = t.artist || '—';
    setCover(t.cover, t.title ? t.title.charAt(0) : '\u266A');
    audio.src = t.src;
  }
})();
