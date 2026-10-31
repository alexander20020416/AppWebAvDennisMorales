using System;
using System.Collections.Generic;
using System.Web;

namespace WebAppPoliMusicV2.Entities
{
    /// <summary>
    /// Entidad que representa un registro de la tabla [TBL_SONG].
    /// ID_SONG    -> ID
    /// SONG_NAME  -> Name
    /// SONG_PATH  -> Path
    /// PLAYS      -> Plays
    /// </summary>
    public class Song
    {
        public Song()
        {
        }

        public Song(int id, string name, string path, int plays)
        {
            ID = id;
            Name = name;
            Path = path;
            Plays = plays;
        }

        public int ID { get; set; }
        public string Name { get; set; }
        public string Path { get; set; }
        public int Plays { get; set; }
    }
}
