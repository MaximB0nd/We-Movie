using System.ComponentModel.DataAnnotations;

namespace WeMovieSync.Core.Models
{
    public class Chat
    {
        public long Id { get; set; }

        public bool IsGroup { get; set; }

        [MaxLength(100)]
        public string? Name { get; set; }  // null для 1:1 чатов

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? LastActivityAt { get; set; }  // обновлять при новом сообщении

        // Навигация
        public ICollection<ChatMember> Members { get; set; } = new List<ChatMember>();
        public ICollection<Message> Messages { get; set; } = new List<Message>();
    }
}