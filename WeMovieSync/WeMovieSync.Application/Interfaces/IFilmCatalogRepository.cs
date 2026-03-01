using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WeMovieSync.Core.Models;
using WeMovieSync.Application.DTOs;
using WeMovieSync.Application.Errors;
using ErrorOr;

namespace WeMovieSync.Application.Interfaces
{
    public interface IFilmCatalogRepository
    {
        // Получение всех фильмов в каталоге
        Task<FilmsResponce> GetAllFilms();

        // Получение полной информации о выбранном фильме
        Task<ErrorOr<FullFilmInfoResponce>> GetFilmById(long token);

        // Проверка что фильм существует
        Task<bool> IsFilmExists(long token);

        Task SaveChangesAsync();
    }
}
