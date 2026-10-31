using System;
using System.Configuration;
using System.Web;

namespace WebAppPoliMusicV2
{
    /// <summary>
    /// Manejador mínimo usado por el reproductor de Song.aspx para incrementar
    /// el contador de reproducciones (TBL_SONG.PLAYS) sin recargar la página.
    /// Responde en formato JSON: { "ok": true, "plays": 5 }
    /// </summary>
    public class SongPlayCounter : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            int idSong;
            if (!int.TryParse(context.Request.QueryString["id"], out idSong) || idSong <= 0)
            {
                context.Response.StatusCode = 400;
                context.Response.Write("{\"ok\":false}");
                return;
            }

            try
            {
                string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
                int plays = new BLL.Song(strConnString).IncrementPlays(idSong);
                context.Response.Write("{\"ok\":true,\"plays\":" + plays + "}");
            }
            catch (Exception)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("{\"ok\":false}");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
