using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeMovieSync.Application.DTOs
{
    public class GetMessagesResponseDTO
    {
        public long MessageId { get; set; }
        public long SenderId { get; set; }
        public long ChatId { get; set; }
        public string? Text { get; set; }
        public DateTime SentAt { get; set; }
        public DateTime? DeliveredAt { get; set; }
        public string SenderName { get; set; } = string.Empty;
        public bool IsRead { get; set; }  
        public bool IsMine { get; set; }
    }
}
