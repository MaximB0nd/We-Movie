using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeMovieSync.Application.DTOs
{
    public class FilmsResponce
    {
        public List<AllFilmsResponce> Films { get; set; } = new();
        public int TotalCount { get; set; }
    }
}
