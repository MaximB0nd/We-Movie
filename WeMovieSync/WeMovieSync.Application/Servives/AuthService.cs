using System;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using BCrypt.Net;
using WeMovieSync.Core.DTOs;
using WeMovieSync.Core.Interfaces;
using WeMovieSync.Core.Models;

namespace WeMovieSync.Core.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUserRepository _userRepository;
        private readonly JwtSettings _jwtSettings; 

        public AuthService(IUserRepository userRepository, JwtSettings jwtSettings)
        {
            _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
            _jwtSettings = jwtSettings ?? throw new ArgumentNullException(nameof(jwtSettings));
        }

        public async Task<object> RegisterAsync(RegisterDTO dto)
        {
            if (await _userRepository.EmailExistsAsync(dto.Email))
                throw new InvalidOperationException("Email уже занят");

            var user = new User
            {
                Email = dto.Email,
                Nickname = dto.NikeName,
                HashedPassword = BCrypt.Net.BCrypt.HashPassword(dto.Password)
            };

            await _userRepository.AddUserAsync(user);

            return new
            {
                user.Id,
                user.Email
            };
        }

        public async Task<object> LoginAsync(LoginDTO dto)
        {
            var user = await _userRepository.GetByEmailAsync(dto.Email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.HashedPassword))
                throw new UnauthorizedAccessException("Неверный email или пароль");

            var accessToken = GenerateJwtToken(user);

            var refreshTokenValue = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
            var refreshToken = new RefreshToken
            {
                Token = refreshTokenValue,
                UserId = user.Id,
                Expires = DateTime.UtcNow.AddDays(30),
                IsRevoked = false
            };

            await _userRepository.AddRefreshTokenAsync(refreshToken);

            return new
            {
                AccessToken = accessToken,
                RefreshToken = refreshTokenValue,
                ExpiresIn = 3600,  // 1 час
                User = new { user.Id, user.Email }
            };
        }

        public async Task<object> RefreshTokenAsync(RefreshRequestDto dto)
        {
            var refreshToken = await _userRepository.GetRefreshTokenAsync(dto.RefreshToken);
            if (refreshToken == null || refreshToken.Expires < DateTime.UtcNow || refreshToken.IsRevoked)
                throw new UnauthorizedAccessException("Недействительный refresh token");

            var user = await _userRepository.GetByIdAsync(refreshToken.UserId);
            if (user == null)
                throw new InvalidOperationException("Пользователь не найден");

            // Отзываем старый токен
            refreshToken.IsRevoked = true;
            refreshToken.RevokedAt = DateTime.UtcNow;
            await _userRepository.UpdateRefreshTokenAsync(refreshToken);

            // Создаём новый
            var newRefreshValue = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
            var newRefresh = new RefreshToken
            {
                Token = newRefreshValue,
                UserId = user.Id,
                Expires = DateTime.UtcNow.AddDays(30),
                IsRevoked = false
            };

            await _userRepository.AddRefreshTokenAsync(newRefresh);

            var newAccessToken = GenerateJwtToken(user);

            return new
            {
                AccessToken = newAccessToken,
                RefreshToken = newRefreshValue
            };
        }

        private string GenerateJwtToken(User user)
        {
            var key = Encoding.UTF8.GetBytes(_jwtSettings.Key);
            var tokenHandler = new JwtSecurityTokenHandler();

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.Email, user.Email)
                }),
                Expires = DateTime.UtcNow.AddMinutes(60),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
                Issuer = _jwtSettings.Issuer,
                Audience = _jwtSettings.Audience
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}