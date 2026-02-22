using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WeMovieSync.Core.Models;
using WeMovieSync.Infrastructure.Context;

namespace WeMovieSync.Infrastructure.Data
{
    public static class FilmsSeeder
    {
        public static async Task Initialize(WeMovieSyncContext context)
        {
            // Cheking that DB already has data
            if (await context.FilmCatalog.AnyAsync())
            {
                return;
            }

            // Test films for inserting in DB
            var films = new List<FilmCatalog>
            {
                new FilmCatalog
                {
                    Token = 1,
                    FilmName = "Интерстеллар",
                    FilmDescription = "Эпическая история о путешествии через червоточину в поисках нового дома для человечества.",
                    Image = await File.ReadAllBytesAsync(Path.Combine("Pictures/interstellar.jpg")),
                    Category = "Научная фантастика",
                    Duration = TimeSpan.FromMinutes(169)
                },
                new FilmCatalog
                {
                    Token = 2,
                    FilmName = "Начало",
                    FilmDescription = "Вор, способный проникать в сны и красть секреты из подсознания, получает задание внедрить идею в разум человека.",
                    Image = await File.ReadAllBytesAsync(Path.Combine("Pictures/begin.jpg")),
                    Category = "Научная фантастика / Боевик",
                    Duration = TimeSpan.FromMinutes(148)
                },
                new FilmCatalog
                {
                    Token = 3,
                    FilmName = "Матрица",
                    FilmDescription = "Хакер Нео узнаёт, что мир — это симуляция, и присоединяется к сопротивлению, чтобы освободить человечество.",
                    Image = await File.ReadAllBytesAsync(Path.Combine("Pictures/matrix.jpg")),
                    Category = "Научная фантастика / Боевик",
                    Duration = TimeSpan.FromMinutes(136)
                }
            };

            context.FilmCatalog.AddRange(films);
            await context.SaveChangesAsync();
        }
    }
}
