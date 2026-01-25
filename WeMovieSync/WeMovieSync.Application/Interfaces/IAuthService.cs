using WeMovieSync.Core.DTOs;

namespace WeMovieSync.Core.Interfaces
{
    public interface IAuthService
    {
        Task<object> RegisterAsync(RegisterDTO dto);
        Task<object> LoginAsync(LoginDTO dto);
        Task<object> RefreshTokenAsync(RefreshRequestDto dto);
    }
}
