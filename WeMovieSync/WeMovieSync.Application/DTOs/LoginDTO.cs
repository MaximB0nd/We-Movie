using System.ComponentModel.DataAnnotations;

namespace WeMovieSync.Application.DTOs
{
    public class LoginDTO
    {
        [Required, EmailAddress]
        public string Email { get; set; } = null!;

        [Required]
        public string Password { get; set; } = null!;
    }
}
