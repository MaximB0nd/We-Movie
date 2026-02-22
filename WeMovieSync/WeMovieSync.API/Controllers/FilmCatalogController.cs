using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WeMovieSync.Application.Interfaces;
using WeMovieSync.Application.Extensions;


namespace WeMovieSync.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FilmCatalogController : ControllerBase
    {
        // Controller with endpoints for filmCatalog

        private readonly IFilmCatalogService _filmCatalogService;

        public FilmCatalogController(IFilmCatalogService filmCatalogService)
        {
            _filmCatalogService = filmCatalogService;
        }

        [Authorize]
        [HttpGet("films")]
        public async Task<IActionResult> GetAllFilmsAsync()
        {
            try
            {
                var result = await _filmCatalogService.GetAllFilms();
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        [Authorize]
        [HttpGet("getfilm=[filmTocken]")]
        public async Task<IActionResult> GetAllFilmsAsync(long filmToken)
        {
            try
            {
                var result = await _filmCatalogService.GetFullFilmInfo(filmToken);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
