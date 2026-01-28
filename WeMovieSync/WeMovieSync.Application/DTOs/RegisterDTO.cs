using System.ComponentModel.DataAnnotations;

namespace WeMovieSync.Application.DTOs
{
    public class RegisterDTO
    {
        [Required, MinLength(2)]
        public string Name { get; set; } = null!;

        [MaxLength(50)]
        public string? Nickname { get; set; }

        [Required, EmailAddress]
        public string Email { get; set; } = null!;

        [Required, MinLength(6)]
        public string Password { get; set; } = null!;
    }
}
