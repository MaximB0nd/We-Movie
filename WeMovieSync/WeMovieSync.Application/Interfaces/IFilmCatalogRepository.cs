using WeMovieSync.Core.Models;
using WeMovieSync.Application.DTOs;
using ErrorOr;

namespace WeMovieSync.Application.Interfaces
{
    public interface IFilmCatalogRepository
    {
        // Получение всех фильмов в каталоге
        Task<FilmsResponce> GetAllFilmsAsync();

        // Получение полной информации о выбранном фильме
        Task<ErrorOr<FullFilmInfoResponce>> GetFilmByIdAsync(long token);

        // Получение объекта фильма из каталога для сервиса чатов
        Task<ErrorOr<FilmCatalog>> GetFilmObjectByIdAsync(long tocken);

        // Проверка что фильм существует
        Task<bool> IsFilmExistsAsync(long token);

        Task SaveChangesAsync();
    }
}
