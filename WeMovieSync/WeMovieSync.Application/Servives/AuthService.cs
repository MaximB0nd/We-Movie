using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using WeMovieSync.Application.Errors;
using ErrorOr;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using WeMovieSync.Application.DTOs;
using WeMovieSync.Application.Interfaces;
using WeMovieSync.Core.Models;

namespace WeMovieSync.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUserRepository _userRepository;
        private readonly IConfiguration _configuration;  // ← читаем настройки напрямую из appsettings.json

        public AuthService(IUserRepository userRepository, IConfiguration configuration)
        {
            _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
            _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        }

        public async Task<ErrorOr<RegistrationResult>> RegisterAsync(RegisterDTO dto)
        {
            if (await _userRepository.EmailExistsAsync(dto.Email))
            {
                return AuthErrors.EmailAlreadyExists;
            }

            var user = new User
            {
                Email = dto.Email,
                Nickname = dto.Nickname,  
                HashedPassword = BCrypt.Net.BCrypt.HashPassword(dto.Password)
            };

            await _userRepository.AddUserAsync(user);

            return new RegistrationResult(user.Nickname, user.Email);
        }
        
        public async Task<ErrorOr<AuthResponse>> LoginAsync(LoginDTO dto)
        {
            var user = await _userRepository.GetByEmailAsync(dto.Email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.HashedPassword))
            {
                return AuthErrors.InvalidCredentials;
            }

            var accessToken = GenerateJwtToken(user);

            var refreshTokenValue = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));

            var hashedToken = Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(refreshTokenValue)));

            var refreshToken = new RefreshToken
            {
                HashedToken = hashedToken,
                UserId = user.Id,
                Expires = DateTime.UtcNow.AddDays(30),
                IsRevoked = false
            };

            await _userRepository.AddRefreshTokenAsync(refreshToken);

            return new AuthResponse(
                AccessToken: accessToken,
                RefreshToken: refreshTokenValue,
                ExpiresIn: 3600,
                User: new UserInfo(user.Nickname, user.Email)
            );
        }

        public async Task<ErrorOr<AuthResponse>> RefreshTokenAsync(RefreshRequestDto dto)
        {
            // 1. Проверяем, что токен вообще прислали
            if (string.IsNullOrWhiteSpace(dto.RefreshToken))
            {
                return Error.Validation("RefreshToken обязателен");
            }

            // 2. Вычисляем SHA256-хэш от plain-токена (один и тот же input → один и тот же хэш)
            var plainRefresh = dto.RefreshToken.Trim();
            var hashedInput = Convert.ToBase64String(
                SHA256.HashData(Encoding.UTF8.GetBytes(plainRefresh))
            );

            // 3. Ищем токен по хэшу
            var refreshToken = await _userRepository.GetRefreshTokenAsync(hashedInput);

            // 4. Проверяем существование, срок и отзыв
            if (refreshToken == null)
            {
                return AuthErrors.InvalidRefreshToken;
            }

            if (refreshToken.Expires < DateTime.UtcNow)
            {
                return AuthErrors.InvalidRefreshToken; // можно отдельную ошибку ExpiredRefreshToken
            }

            if (refreshToken.IsRevoked)
            {
                return AuthErrors.InvalidRefreshToken;
            }

            // 5. Получаем пользователя
            var user = await _userRepository.GetByIdAsync(refreshToken.UserId);
            if (user == null)
            {
                return AuthErrors.UserNotFound;
            }

            // 6. Отзываем старый токен
            refreshToken.IsRevoked = true;
            refreshToken.RevokedAt = DateTime.UtcNow;
            await _userRepository.UpdateRefreshTokenAsync(refreshToken);

            // 7. Генерируем новый plain-токен и его хэш
            var newRefreshValue = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
            var newHashedToken = Convert.ToBase64String(
                SHA256.HashData(Encoding.UTF8.GetBytes(newRefreshValue))
            );

            var newRefresh = new RefreshToken
            {
                HashedToken = newHashedToken,
                UserId = user.Id,
                Expires = DateTime.UtcNow.AddDays(30),
                IsRevoked = false
            };

            await _userRepository.AddRefreshTokenAsync(newRefresh);

            // 8. Новый access-токен
            var newAccessToken = GenerateJwtToken(user);

            // 9. Возвращаем клиенту
            return new AuthResponse(
                AccessToken: newAccessToken,
                RefreshToken: newRefreshValue,          // отдаём plain-токен клиенту
                ExpiresIn: 3600,
                User: new UserInfo(user.Nickname, user.Email)
            );
        }

        private string GenerateJwtToken(User user)
        {
            var key = Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!);
            var tokenHandler = new JwtSecurityTokenHandler();

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.Email, user.Email)
                }),
                Expires = DateTime.UtcNow.AddMinutes(60),
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(key),
                    SecurityAlgorithms.HmacSha256Signature
                ),
                Issuer = _configuration["Jwt:Issuer"],
                Audience = _configuration["Jwt:Audience"]
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}