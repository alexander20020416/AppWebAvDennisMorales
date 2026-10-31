using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    /// <summary>
    /// Página principal del usuario autenticado: muestra el listado de canciones
    /// de la tabla TBL_SONG y permite reproducirlas.
    /// </summary>
    public partial class Song : System.Web.UI.Page
    {
        private string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        #region Propiedades
        /// <summary>
        /// Usuario autenticado guardado en sesión durante el login.
        /// </summary>
        private Entities.User CurrentUser
        {
            get { return Session[Util.Constants.USER] as Entities.User; }
        }
        #endregion

        #region Eventos de la página
        protected void Page_Load(object sender, EventArgs e)
        {
            // La sesión es obligatoria: sin usuario autenticado se vuelve al login.
            if (CurrentUser == null)
            {
                FormsAuthentication.RedirectToLoginPage();
                return;
            }

            if (!Page.IsPostBack)
            {
                LoadUserInformation();
                BindSongList(string.Empty);
            }
        }

        protected void BtnSearch_Click(object sender, EventArgs e)
        {
            BindSongList(txtSearch.Text.Trim());
        }

        protected void LnkClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            BindSongList(string.Empty);
        }

        protected void LnkLogout_Click(object sender, EventArgs e)
        {
            // Cierra la sesión del usuario y regresa al login.
            FormsAuthentication.SignOut();
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx", true);
        }
        #endregion

        #region Carga de datos
        /// <summary>
        /// Muestra en pantalla el nombre del usuario autenticado (Welcome),
        /// su rol y su fotografía de perfil.
        /// </summary>
        private void LoadUserInformation()
        {
            Entities.User user = CurrentUser;

            string displayName = user.UserName;
            if (string.IsNullOrEmpty(displayName))
            {
                displayName = User.Identity.Name;
            }

            string safeName = HttpUtility.HtmlEncode(displayName);
            string photoUrl = GetUserPhotoUrl(user.Photo);

            lblUserName.Text = safeName;
            lblWelcomeName.Text = safeName;

            imgAvatar.Src = photoUrl;
            imgAvatar.Alt = "Foto de perfil de " + displayName;

            imgHeroAvatar.Src = photoUrl;
            imgHeroAvatar.Alt = string.Empty;

            lblRole.Text = (user.UserType == Util.Constants.ID_USER_ADMIN) ? "Administrador" : "Usuario";
        }

        /// <summary>
        /// Consulta la BLL (que a su vez llama a la DAL) y enlaza las canciones al Repeater.
        /// </summary>
        private void BindSongList(string filter)
        {
            BLL.Song bllSong = new BLL.Song(strConnString);
            DataTable dtSongs;

            if (string.IsNullOrEmpty(filter))
            {
                dtSongs = bllSong.Read();
                lblMessage.Visible = false;
                lblMessage.Text = string.Empty;
            }
            else
            {
                dtSongs = bllSong.Search(filter);
                lblMessage.Visible = true;
                lblMessage.Text = HttpUtility.HtmlEncode(
                    string.Format("{0} resultado(s) para «{1}»", dtSongs.Rows.Count, filter));
            }

            rptSongs.DataSource = dtSongs;
            rptSongs.DataBind();

            pnlEmpty.Visible = (dtSongs == null || dtSongs.Rows.Count == 0);
            UpdateStatistics(dtSongs);
        }

        /// <summary>
        /// Calcula el total de canciones y de reproducciones para la cabecera.
        /// </summary>
        private void UpdateStatistics(DataTable dtSongs)
        {
            int totalSongs = 0;
            int totalPlays = 0;

            if (dtSongs != null)
            {
                totalSongs = dtSongs.Rows.Count;
                foreach (DataRow row in dtSongs.Rows)
                {
                    if (row["PLAYS"] != DBNull.Value)
                    {
                        totalPlays += Convert.ToInt32(row["PLAYS"]);
                    }
                }
            }

            lblTotalSongs.Text = totalSongs.ToString();
            lblTotalPlays.Text = totalPlays.ToString();
        }
        #endregion

        #region Helpers usados desde el diseño (Song.aspx)
        protected string SongName(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value));
        }

        protected string SongPath(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value));
        }

        protected string PlaysText(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return "0";
            }
            int plays;
            if (!int.TryParse(value.ToString(), out plays))
            {
                return "0";
            }
            return plays.ToString();
        }

        /// <summary>
        /// Convierte la ruta almacenada en la base (~/songFiles/...) en una URL
        /// válida para el reproductor de audio.
        /// </summary>
        protected string AudioUrl(object value)
        {
            string path = Convert.ToString(value);
            if (string.IsNullOrEmpty(path))
            {
                return string.Empty;
            }
            return ResolveUrl(path);
        }

        protected string PlayLabel(object name)
        {
            return HttpUtility.HtmlEncode("Reproducir " + Convert.ToString(name));
        }

        protected string SeekLabel(object name)
        {
            return HttpUtility.HtmlEncode("Progreso de " + Convert.ToString(name));
        }

        protected string VolumeLabel(object name)
        {
            return HttpUtility.HtmlEncode("Volumen de " + Convert.ToString(name));
        }

        protected string MuteLabel(object name)
        {
            return HttpUtility.HtmlEncode("Silenciar " + Convert.ToString(name));
        }
        #endregion

        #region Utilidades
        private string GetUserPhotoUrl(string photo)
        {
            if (string.IsNullOrEmpty(photo))
            {
                return ResolveUrl("~/UserImages/default.jpg");
            }
            return ResolveUrl(photo);
        }
        #endregion
    }
}
