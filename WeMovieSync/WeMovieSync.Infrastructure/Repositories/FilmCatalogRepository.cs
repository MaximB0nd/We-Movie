using Microsoft.EntityFrameworkCore;
using WeMovieSync.Application.DTOs;
using WeMovieSync.Application.Interfaces;
using WeMovieSync.Infrastructure.Context;
using WeMovieSync.Application.Errors;
using ErrorOr;
using WeMovieSync.Core.Models;

namespace WeMovieSync.Infrastructure.Repositories
{
    public class FilmCatalogRepository : IFilmCatalogRepository
        {
            private readonly WeMovieSyncContext _context;

            public FilmCatalogRepository(WeMovieSyncContext context )
            {
                _context = context ?? throw new ArgumentNullException(nameof(context));
            }

            // Getting all films with totalcount
            public async Task<FilmsResponce> GetAllFilmsAsync()
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

        // Getting object of film
        public async Task<ErrorOr<FilmCatalog>> GetFilmObjectByIdAsync(long token)
        {
            var film = await _context.FilmCatalog
                .AsNoTracking()
                .Where(f => f.Token == token)
                .FirstOrDefaultAsync();

            if (film == null) {
                return FilmCatalogErrors.FilmNotFoundByToken(token);
            }

            return film;
        }

            // Getting full info about film by token
            public async Task<ErrorOr<FullFilmInfoResponce>> GetFilmByIdAsync(long token)
            {   
                var film = await _context.FilmCatalog
                    .AsNoTracking()
                    .Where(f => f.Token == token)
                    .Select(f => new FullFilmInfoResponce
                    {
                        Token = f.Token,
                        FilmName = f.FilmName,
                        FilmDescription = f.FilmDescription,
                        Image = f.Image,
                        Category = f.Category,
                        Duration = f.Duration
                    })
                    .FirstOrDefaultAsync();

            if (film == null)
                return FilmCatalogErrors.FilmNotFoundByToken(token);

            return film;
            }
        
        // Checking film existince
        public async Task<bool> IsFilmExistsAsync(long token)
        {
            return await _context.FilmCatalog
                .AnyAsync(f => f.Token == token);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
