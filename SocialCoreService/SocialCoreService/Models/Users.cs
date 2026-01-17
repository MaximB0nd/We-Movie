using System.ComponentModel.DataAnnotations;  

namespace SocialCoreService.Models
{
    public class Users
    {
        [Key]
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public string Nickname { get; set; }
        public string HashedPassword { get; set; }

        public List<RefreshToken> RefreshTokens { get; set; } = new();

    }
}
