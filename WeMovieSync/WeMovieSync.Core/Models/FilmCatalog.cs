using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeMovieSync.Core.Models
{
    public class FilmCatalog
    {
        [Key]
        public long Token { get; set; }

        [Required]
        public string? FilmName { get; set; }
        
        [Required]
        public string? FilmDescription { get; set; }

        public byte[]? Image { get; set; }
        public string? Category { get; set; }
        public TimeSpan? Duration { get; set; }

    }
}
