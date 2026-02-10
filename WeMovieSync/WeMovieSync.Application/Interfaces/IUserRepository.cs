using WeMovieSync.Core.Models;


namespace WeMovieSync.Application.Interfaces
{
    public interface IUserRepository
    {
        Task<bool> EmailExistsAsync(string email);
        Task<bool> NickExistsAsync(string Nick);
        Task AddUserAsync(User user);
        Task<User?> GetByEmailAsync(string email);
        Task<User?> GetByNickAsync(string Nick);
        Task<User?> GetByIdAsync(long id);
        Task AddRefreshTokenAsync(RefreshToken token);
        Task<RefreshToken?> GetRefreshTokenAsync(string token);
        Task UpdateRefreshTokenAsync(RefreshToken token);
    }
}
