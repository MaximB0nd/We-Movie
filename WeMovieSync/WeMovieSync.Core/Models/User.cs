using System.ComponentModel.DataAnnotations;  

namespace WeMovieSync.Core.Models
{
    public class User
    {
        [Key]
        public long Id { get; set; }
        public string? Email { get; set; }
        public string? Nickname { get; set; }
        public string? HashedPassword { get; set; }

        public List<RefreshToken> RefreshTokens { get; set; } = new();
        public List<ChatMember> ChatMembers { get; set; } = new();
        public List<Message> SentMessages { get; set; } = new();
        public List<MessageRead> ReadMessages { get; set; } = new();

    }
}
