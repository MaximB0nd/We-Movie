using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WeMovieSync.Application.DTOs;
using ErrorOr;

namespace WeMovieSync.Application.Interfaces
{
    public interface IFilmCatalogService
    {
        Task<ErrorOr<FilmsResponce>> GetAllFilms();
        Task<ErrorOr<FullFilmInfoResponce>> GetFullFilmInfo(long token);
    }
}
