using BCrypt.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SocialCoreService.Context;
using SocialCoreService.DTOs;
using SocialCoreService.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Security.Cryptography;


namespace SocialCoreService.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly SocialCoreContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(SocialCoreContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDTO dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (await _context.Users.AnyAsync(u => u.Email == dto.Email))
                return BadRequest("Email уже занят");

            var user = new Users
            {
                UserName = dto.Name,
                Email = dto.Email,
                Nickname = dto.NikeName,
                HashedPassword = BCrypt.Net.BCrypt.HashPassword(dto.Password)
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(new { user.UserId, user.UserName, user.Email });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDTO dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.HashedPassword))
                return Unauthorized("Неверный email или пароль");

            var accessToken = GenerateJwtToken(user);

            // Генерация refresh-токена
            var refreshTokenValue = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
            var refreshToken = new RefreshToken
            {
                Token = refreshTokenValue, // plain-токен
                UserId = user.UserId,
                Expires = DateTime.UtcNow.AddDays(30),
                IsRevoked = false
            };

            _context.RefreshTokens.Add(refreshToken);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                AccessToken = accessToken,
                RefreshToken = refreshTokenValue, // отдаём plain-токен клиенту
                ExpiresIn = (int)(DateTime.UtcNow.AddHours(1) - DateTime.UtcNow).TotalSeconds,
                User = new { user.UserId, user.UserName, user.Email }
            });
        }

        [HttpPost("refresh")]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequestDto dto)
        {
            var hashedRefresh = BCrypt.Net.BCrypt.HashPassword(dto.RefreshToken);

            var refreshToken = await _context.RefreshTokens
                .FirstOrDefaultAsync(rt => rt.Token == dto.RefreshToken && rt.Expires > DateTime.UtcNow && !rt.IsRevoked);

            if (refreshToken == null)
                return Unauthorized("Недействительный refresh token");

            var user = await _context.Users.FindAsync(refreshToken.UserId);
            if (user == null)
                return Unauthorized("Пользователь не найден");

            // Отзываем старый
            refreshToken.IsRevoked = true;
            refreshToken.RevokedAt = DateTime.UtcNow;

            // Создаём новый
            var newRefreshValue = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
            var newRefresh = new RefreshToken
            {
                Token = BCrypt.Net.BCrypt.HashPassword(newRefreshValue),
                UserId = user.UserId,
                Expires = DateTime.UtcNow.AddDays(30),
                IsRevoked = false
            };

            _context.RefreshTokens.Add(newRefresh);
            await _context.SaveChangesAsync();

            var newAccessToken = GenerateJwtToken(user);

            return Ok(new
            {
                AccessToken = newAccessToken,
                RefreshToken = newRefreshValue
            });
        }


        private string GenerateJwtToken(Users user)
        {
            var key = Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!);
            var tokenHandler = new JwtSecurityTokenHandler();

            var tokenDescriptor = new Microsoft.IdentityModel.Tokens.SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                    new Claim(ClaimTypes.Name, user.UserName ?? ""),
                    new Claim(ClaimTypes.Email, user.Email)
                }),
                Expires = DateTime.UtcNow.AddMinutes(60),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
                Issuer = _configuration["Jwt:Issuer"],
                Audience = _configuration["Jwt:Audience"]
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}