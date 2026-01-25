using System.ComponentModel.DataAnnotations;  

namespace WeMovieSync.Core.Models
{
    public class User
    {
        [Key]
        public int Id { get; set; }
        public string? Email { get; set; }
        public string? Nickname { get; set; }
        public string? HashedPassword { get; set; }

        public List<RefreshToken> RefreshTokens { get; set; } = new();

    }
}
