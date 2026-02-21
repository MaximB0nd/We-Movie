using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeMovieSync.Application.DTOs
{
    public class FullFilmInfoResponce
    {
        public long Token { get; set; }
        public string? FilmName { get; set; }
        public string? FilmDescription { get; set; }
        public byte[]? Image { get; set; }
        public string? Category { get; set; }
        public TimeSpan? Duration { get; set; }
    }
}
