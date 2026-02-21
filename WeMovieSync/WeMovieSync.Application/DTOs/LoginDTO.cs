using System.ComponentModel.DataAnnotations;

namespace WeMovieSync.Application.DTOs
{
    public class LoginDTO
    {
        public string? Email { get; set; }
        public string? Nickname { get; set; }

        [Required]
        [MinLength(6)]
        public string Password { get; set; } = null!;
    }
}
