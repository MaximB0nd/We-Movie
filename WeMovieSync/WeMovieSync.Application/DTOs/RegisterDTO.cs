using System.ComponentModel.DataAnnotations;

namespace WeMovieSync.Core.DTOs
{
    public class RegisterDTO
    {
        [Required(ErrorMessage = "Имя обязательно")]
        [MinLength(2, ErrorMessage = "Имя должно быть длиннее 2 символов")]
        public string Name { get; set; } = "";

        public string? NikeName { get; set; }    

        [Required]
        [EmailAddress(ErrorMessage = "Некорректный email")]
        public string Email { get; set; } = "";

        [Required, MinLength(6)]
        public string Password { get; set; } = "";
    }
}
