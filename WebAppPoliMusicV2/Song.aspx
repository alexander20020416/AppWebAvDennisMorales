<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html lang="es" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#060A14" />
    <meta name="description" content="PoliMusic - Listado de canciones disponibles para el usuario autenticado." />
    <title>PoliMusic &middot; Song list</title>
    <link rel="stylesheet" href="css/Song.css" />
</head>
<body>
    <a class="skip-link" href="#songListTitle">Saltar al listado de canciones</a>

    <form id="formSong" runat="server">

        <!-- ===================== Barra superior ===================== -->
        <header class="topbar">
            <div class="topbar-inner">
                <a class="brand" href="Song.aspx" aria-label="PoliMusic, ir al listado de canciones">
                    <span class="brand-mark" aria-hidden="true">
                        <svg viewBox="0 0 24 24" focusable="false"><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z" /></svg>
                    </span>
                    <span class="brand-text">Poli<span>Music</span></span>
                </a>

                <div class="search" role="search">
                    <asp:Label ID="lblSearch" runat="server" AssociatedControlID="txtSearch" CssClass="sr-only" Text="Buscar canción por nombre" />
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Buscar canción..." autocomplete="off" />
                    <asp:Button ID="btnSearch" runat="server" CssClass="search-btn" Text="Buscar" OnClick="BtnSearch_Click" />
                    <asp:LinkButton ID="lnkClear" runat="server" CssClass="search-clear" OnClick="LnkClear_Click">Limpiar</asp:LinkButton>
                </div>

                <div class="user-chip">
                    <img id="imgAvatar" runat="server" class="avatar" alt="" />
                    <span class="user-meta">
                        <span class="user-label">Sesión activa</span>
                        <asp:Label ID="lblUserName" runat="server" CssClass="user-name" />
                    </span>
                </div>
            </div>
        </header>

        <main class="page">

            <!-- ===================== Bienvenida ===================== -->
            <section class="hero" aria-labelledby="welcomeTitle">
                <div class="hero-inner">
                    <img id="imgHeroAvatar" runat="server" class="hero-avatar" alt="" />
                    <div class="hero-text">
                        <p class="hero-eyebrow">Sesión iniciada</p>
                        <h1 id="welcomeTitle" class="hero-title">
                            Welcome <span class="hl"><asp:Label ID="lblWelcomeName" runat="server" /></span>
                        </h1>
                        <p class="hero-sub">
                            <asp:Label ID="lblRole" runat="server" CssClass="pill" />
                            <span class="dot" aria-hidden="true">&bull;</span>
                            <span><asp:Label ID="lblTotalSongs" runat="server" /> canciones</span>
                            <span class="dot" aria-hidden="true">&bull;</span>
                            <span><asp:Label ID="lblTotalPlays" runat="server" /> reproducciones</span>
                        </p>
                    </div>
                </div>

                <div class="hero-actions">
                    <asp:LinkButton ID="lnkLogout" runat="server" CssClass="btn-logout" OnClick="LnkLogout_Click" CausesValidation="false">Logout</asp:LinkButton>
                </div>
            </section>

            <!-- ===================== Listado ===================== -->
            <section class="panel" aria-labelledby="songListTitle">
                <div class="panel-head">
                    <div>
                        <h2 id="songListTitle" class="panel-title">Song list:</h2>
                        <p class="panel-desc" id="songListDesc">Canciones registradas en la tabla TBL_SONG. Usa el botón de reproducción para escuchar cada pista.</p>
                    </div>
                    <asp:Label ID="lblMessage" runat="server" CssClass="notice" role="status" Visible="false" />
                </div>

                <div class="table-wrap">
                    <table class="song-table" aria-describedby="songListDesc">
                        <caption class="sr-only">Listado de canciones con identificador, nombre, ruta del archivo, número de reproducciones y reproductor de audio</caption>
                        <thead>
                            <tr>
                                <th scope="col" class="col-id">ID Canci&oacute;n</th>
                                <th scope="col" class="col-name">Nombre</th>
                                <th scope="col" class="col-path">Ruta</th>
                                <th scope="col" class="col-plays">Reproducciones</th>
                                <th scope="col" class="col-player">Reproducir</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptSongs" runat="server">
                                <ItemTemplate>
                                    <tr class="song-row" data-row data-song-id='<%# Eval("ID_SONG") %>'>
                                        <td class="col-id">
                                            <span class="badge-id"><%# Eval("ID_SONG") %></span>
                                        </td>
                                        <td class="col-name">
                                            <span class="song-title"><%# SongName(Eval("SONG_NAME")) %></span>
                                        </td>
                                        <td class="col-path">
                                            <code class="path"><%# SongPath(Eval("SONG_PATH")) %></code>
                                        </td>
                                        <td class="col-plays">
                                            <span class="plays" data-plays><%# PlaysText(Eval("PLAYS")) %></span>
                                        </td>
                                        <td class="col-player">
                                            <div class="player" data-player>
                                                <button type="button" class="btn-play" data-play data-name='<%# SongName(Eval("SONG_NAME")) %>' aria-label='<%# PlayLabel(Eval("SONG_NAME")) %>' aria-pressed="false">
                                                    <svg class="i-play" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M8 5v14l11-7z" /></svg>
                                                    <svg class="i-pause" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M7 5h4v14H7zM13 5h4v14h-4z" /></svg>
                                                </button>
                                                <span class="time"><span data-current>0:00</span> / <span data-duration>0:00</span></span>
                                                <input type="range" class="seek" data-seek min="0" max="100" step="0.1" value="0" aria-label='<%# SeekLabel(Eval("SONG_NAME")) %>' />
                                                <button type="button" class="btn-ghost" data-mute aria-label='<%# MuteLabel(Eval("SONG_NAME")) %>' aria-pressed="false">
                                                    <svg class="i-volume" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M4 9v6h4l5 4V5L8 9H4zm12.5 3a4.5 4.5 0 0 0-2.5-4v8a4.5 4.5 0 0 0 2.5-4z" /></svg>
                                                    <svg class="i-muted" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M4 9v6h4l5 4V5L8 9H4zm12.7 3 2.3-2.3-1.4-1.4-2.3 2.3-2.3-2.3-1.4 1.4L13.9 12l-2.3 2.3 1.4 1.4 2.3-2.3 2.3 2.3 1.4-1.4z" /></svg>
                                                </button>
                                                <input type="range" class="vol" data-vol min="0" max="100" step="1" value="80" aria-label='<%# VolumeLabel(Eval("SONG_NAME")) %>' />
                                                <audio data-audio preload="none" src='<%# AudioUrl(Eval("SONG_PATH")) %>'></audio>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>

                <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                    <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z" /></svg>
                    <p class="empty-title">No hay canciones para mostrar</p>
                    <p class="empty-desc">La tabla TBL_SONG no devolvió registros con el criterio indicado.</p>
                </asp:Panel>
            </section>

        </main>
    </form>

    <script type="text/javascript">
        (function () {
            "use strict";

            function formatTime(seconds) {
                if (!isFinite(seconds) || seconds < 0) {
                    seconds = 0;
                }
                var minutes = Math.floor(seconds / 60);
                var rest = Math.floor(seconds % 60);
                return minutes + ":" + (rest < 10 ? "0" + rest : rest);
            }

            function countPlay(songId, playsNode) {
                if (!songId) {
                    return;
                }
                var request = new XMLHttpRequest();
                request.open("GET", "SongPlayCounter.ashx?id=" + encodeURIComponent(songId), true);
                request.onreadystatechange = function () {
                    if (request.readyState !== 4 || request.status !== 200 || !playsNode) {
                        return;
                    }
                    try {
                        var data = JSON.parse(request.responseText);
                        if (data && typeof data.plays === "number") {
                            playsNode.textContent = data.plays;
                            playsNode.classList.add("bump");
                            window.setTimeout(function () {
                                playsNode.classList.remove("bump");
                            }, 600);
                        }
                    } catch (error) {
                        /* Si el contador falla, la reproducción continúa sin afectar la página. */
                    }
                };
                request.send();
            }

            var currentAudio = null;

            function initPlayer(player) {
                var audio = player.querySelector("[data-audio]");
                var playButton = player.querySelector("[data-play]");
                var seek = player.querySelector("[data-seek]");
                var volume = player.querySelector("[data-vol]");
                var muteButton = player.querySelector("[data-mute]");
                var currentTimeNode = player.querySelector("[data-current]");
                var durationNode = player.querySelector("[data-duration]");
                var row = player.closest("tr");
                var playsNode = row ? row.querySelector("[data-plays]") : null;
                var songId = row ? row.getAttribute("data-song-id") : null;
                var songName = playButton.getAttribute("data-name") || "";
                var counted = false;
                var isSeeking = false;

                if (!audio) {
                    return;
                }

                function setProgress() {
                    var duration = audio.duration;
                    var percent = (isFinite(duration) && duration > 0) ? (audio.currentTime / duration) * 100 : 0;
                    seek.value = percent;
                    seek.style.setProperty("--progress", percent + "%");
                    currentTimeNode.textContent = formatTime(audio.currentTime);
                    seek.setAttribute("aria-valuetext", formatTime(audio.currentTime) + " de " + formatTime(duration));
                }

                function setPlaying(state) {
                    player.classList.toggle("is-playing", state);
                    if (row) {
                        row.classList.toggle("is-playing", state);
                    }
                    playButton.setAttribute("aria-pressed", state ? "true" : "false");
                    playButton.setAttribute("aria-label", (state ? "Pausar " : "Reproducir ") + songName);
                }

                playButton.addEventListener("click", function () {
                    if (audio.paused) {
                        var promise = audio.play();
                        if (promise && typeof promise.catch === "function") {
                            promise.catch(function () {
                                playButton.setAttribute("aria-label", "No se pudo reproducir " + songName);
                            });
                        }
                    } else {
                        audio.pause();
                    }
                });

                audio.addEventListener("play", function () {
                    if (currentAudio && currentAudio !== audio) {
                        currentAudio.pause();
                    }
                    currentAudio = audio;
                    setPlaying(true);
                    if (!counted) {
                        counted = true;
                        countPlay(songId, playsNode);
                    }
                });

                audio.addEventListener("pause", function () {
                    setPlaying(false);
                });

                audio.addEventListener("ended", function () {
                    setPlaying(false);
                    seek.value = 0;
                    seek.style.setProperty("--progress", "0%");
                    currentTimeNode.textContent = formatTime(0);
                });

                audio.addEventListener("loadedmetadata", function () {
                    durationNode.textContent = formatTime(audio.duration);
                    setProgress();
                });

                audio.addEventListener("timeupdate", function () {
                    if (!isSeeking) {
                        setProgress();
                    }
                });

                seek.addEventListener("input", function () {
                    isSeeking = true;
                    if (isFinite(audio.duration) && audio.duration > 0) {
                        audio.currentTime = (seek.value / 100) * audio.duration;
                        currentTimeNode.textContent = formatTime(audio.currentTime);
                    }
                    seek.style.setProperty("--progress", seek.value + "%");
                });

                seek.addEventListener("change", function () {
                    isSeeking = false;
                });

                volume.addEventListener("input", function () {
                    audio.volume = volume.value / 100;
                    volume.style.setProperty("--progress", volume.value + "%");
                    if (audio.volume > 0 && audio.muted) {
                        audio.muted = false;
                        muteButton.setAttribute("aria-pressed", "false");
                        muteButton.setAttribute("aria-label", "Silenciar " + songName);
                    }
                });

                muteButton.addEventListener("click", function () {
                    audio.muted = !audio.muted;
                    muteButton.setAttribute("aria-pressed", audio.muted ? "true" : "false");
                    muteButton.setAttribute("aria-label", (audio.muted ? "Activar sonido de " : "Silenciar ") + songName);
                });

                audio.volume = volume.value / 100;
                volume.style.setProperty("--progress", volume.value + "%");
            }

            var players = document.querySelectorAll("[data-player]");
            Array.prototype.forEach.call(players, initPlayer);
        }());
    </script>
</body>
</html>
