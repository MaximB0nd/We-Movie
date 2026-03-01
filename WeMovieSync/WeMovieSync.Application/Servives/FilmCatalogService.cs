using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WeMovieSync.Application.DTOs;
using WeMovieSync.Application.Interfaces;
using ErrorOr;
using WeMovieSync.Application.Errors;

namespace WeMovieSync.Application.Servives
{
    public class FilmCatalogService : IFilmCatalogService
    {
        private readonly IFilmCatalogRepository _filmCatalogRepository;

        public FilmCatalogService(IFilmCatalogRepository filmCatalogRepository)
        {
            _filmCatalogRepository = filmCatalogRepository;
        }

        public async Task<ErrorOr<FilmsResponce>> GetAllFilms()
        {
            return await _filmCatalogRepository.GetAllFilms();
        }

        public async Task<ErrorOr<FullFilmInfoResponce>> GetFullFilmInfo(long token)
        {
            if (!await _filmCatalogRepository.IsFilmExists(token)) {
                return FilmCatalogErrors.FilmNotFound(token);
            }

            return await _filmCatalogRepository.GetFilmById(token);
        }
    }
}
