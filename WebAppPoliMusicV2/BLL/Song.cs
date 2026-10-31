using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    /// <summary>
    /// Capa de lógica de negocio (Business Logic Layer) para las canciones.
    /// Su única responsabilidad es validar y delegar la llamada hacia la DAL.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Save(song);
        }

        public DataTable Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }

        public DataTable ReadById(int idSong)
        {
            return new DAL.Song(strConnectionString).ReadById(idSong);
        }

        public DataTable Search(string text)
        {
            return new DAL.Song(strConnectionString).Search(text);
        }

        public int Update(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Update(song);
        }

        public int Delete(int idSong)
        {
            return new DAL.Song(strConnectionString).Delete(idSong);
        }

        public int IncrementPlays(int idSong)
        {
            return new DAL.Song(strConnectionString).IncrementPlays(idSong);
        }

        public int CheckExistSong(string songName)
        {
            return new DAL.Song(strConnectionString).CheckExistSong(songName);
        }

        public string ValidationsRequired(Entities.Song song)
        {
            if (song == null)
            {
                return "The song information is required!";
            }
            if (string.IsNullOrEmpty(song.Name) || song.Name.Trim() == string.Empty)
            {
                return "Song name is required!";
            }
            if (song.Name.Length > 50)
            {
                return "Song name cannot exceed 50 characters!";
            }
            if (string.IsNullOrEmpty(song.Path) || song.Path.Trim() == string.Empty)
            {
                return "Song path is required!";
            }
            if (song.Path.Length > 255)
            {
                return "Song path cannot exceed 255 characters!";
            }
            if (song.Plays < 0)
            {
                return "Plays cannot be a negative number!";
            }
            return string.Empty;
        }

        public string ValidationsDuplicated(Entities.Song song)
        {
            if (CheckExistSong(song.Name) != 0)
            {
                return "Song name already registered!";
            }
            return string.Empty;
        }
    }
}
