using ErrorOr;

using WeMovieSync.Application.DTOs;

namespace WeMovieSync.Application.Interfaces
{
    public interface IAuthService
    {
        Task<ErrorOr<RegistrationResult>> RegisterAsync(RegisterDTO dto);
        Task<ErrorOr<AuthResponse>> LoginAsync(LoginDTO dto);
        Task<ErrorOr<AuthResponse>> RefreshTokenAsync(RefreshRequestDto dto);
    }
}
