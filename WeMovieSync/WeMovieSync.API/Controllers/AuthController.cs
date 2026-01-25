using Microsoft.AspNetCore.Mvc;
using WeMovieSync.Application.Interfaces;
using WeMovieSync.Application.DTOs;
using System.Threading.Tasks;


namespace MovieSync.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDTO dto)
        {
            try
            {
                var result = await _authService.RegisterAsync(dto);
                return Ok(result);
            }
            catch (ArgumentException)
            {
                return BadRequest("Problem with data"); 
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDTO dto)
        {
            try
            {
                var result = await _authService.LoginAsync(dto);
                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized("401 — incorrect password/email"); 
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("refresh")]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequestDto dto)
        {
            try
            {
                var result = await _authService.RefreshTokenAsync(dto);
                return Ok(result);
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }
    }
}