using Microsoft.AspNetCore.Mvc.ModelBinding.Binders;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeMovieSync.Application.DTOs
{
    public class AllFilmsResponce
    {
        public long FilmId { get; set; }
        public long TotalCount { get; set; }
        public string? Name { get; set; }
        public byte[]? Image { get; set; }
    }
}
