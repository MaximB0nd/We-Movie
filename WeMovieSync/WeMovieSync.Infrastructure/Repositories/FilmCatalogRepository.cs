    using Microsoft.EntityFrameworkCore;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading.Tasks;
    using WeMovieSync.Application.DTOs;
    using WeMovieSync.Application.Interfaces;
    using WeMovieSync.Infrastructure.Context;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

    namespace WeMovieSync.Infrastructure.Repositories
    {
        public class FilmCatalogRepository : IFilmCatalogRepository
        {
            private readonly WeMovieSyncContext _context;

            public FilmCatalogRepository( WeMovieSyncContext context )
            {
                _context = context;
            }

            // Getting all films with totalcount
            public async Task<FilmsResponce> GetAllFilms()
            {
            var query = _context.FilmCatalog
                .AsNoTracking()
                .AsQueryable();

            var totalCount = await query.CountAsync();

            var films = await query
                 .Select(f => new AllFilmsResponce
                 {
                    Token = f.Token,
                    Name = f.FilmName,
                    Image = f.Image
                 })
                 .ToListAsync();

            return new FilmsResponce
            {
                Films = films,
                TotalCount = totalCount
            };      
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
