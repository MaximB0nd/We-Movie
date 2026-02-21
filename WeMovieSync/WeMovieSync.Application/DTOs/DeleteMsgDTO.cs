using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeMovieSync.Application.DTOs
{
    public class DeleteMsgDTO
    {
        public long MessageId { get; set; }
        public bool forEveryone { get; set; }
    }
}
