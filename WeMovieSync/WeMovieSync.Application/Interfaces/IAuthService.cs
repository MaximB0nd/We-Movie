using WeMovieSync.Application.DTOs;

namespace WeMovieSync.Application.Interfaces
{
    public interface IAuthService
    {
        Task<object> RegisterAsync(RegisterDTO dto);
        Task<object> LoginAsync(LoginDTO dto);
        Task<object> RefreshTokenAsync(RefreshRequestDto dto);
    }
}
