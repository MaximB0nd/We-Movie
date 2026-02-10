using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;


namespace WeMovieSync.Core.Models
{
    public class User
    {
        [Key]
        public long Id { get; set; }

        [Required]
        [EmailAddress]
        public string? Email { get; set; }
        [Required]
        [MinLength(3)]
        [MaxLength(32)]
        public string? Nickname { get; set; }
        public string? HashedPassword { get; set; }

        public List<RefreshToken> RefreshTokens { get; set; } = new();
        public List<ChatMember> ChatMembers { get; set; } = new();
        public List<Message> SentMessages { get; set; } = new();
        public List<MessageRead> ReadMessages { get; set; } = new();

    }
}
