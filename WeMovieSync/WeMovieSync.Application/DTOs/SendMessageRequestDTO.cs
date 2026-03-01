using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeMovieSync.Application.DTOs
{
    public class SendMessageRequestDTO
    {
        public long ChatId { get; set; }
        public string Text { get; set; } = string.Empty;
    }
}
