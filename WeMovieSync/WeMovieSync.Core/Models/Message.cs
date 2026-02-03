using System.ComponentModel.DataAnnotations;

namespace WeMovieSync.Core.Models
{
    public class Message
    {
        public long Id { get; set; }

        public long ChatId { get; set; }

        public long SenderId { get; set; }

        [Required]
        [MaxLength(4096)]  // ограничение на длину сообщения
        public string Text { get; set; } = string.Empty;

        public DateTime SentAt { get; set; } = DateTime.UtcNow;

        public DateTime? DeliveredAt { get; set; }

        public bool IsEdited { get; set; } = false;
        public DateTime? EditedAt { get; set; }

        // Навигация
        public Chat Chat { get; set; } = null!;
        public User Sender { get; set; } = null!;
        public ICollection<MessageRead> Reads { get; set; } = new List<MessageRead>();
    }
}