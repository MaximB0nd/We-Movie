using System;
using ErrorOr;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WeMovieSync.Application.DTOs;
using System.Threading.Tasks;

namespace WeMovieSync.Application.Interfaces
{
    public interface IMsgService
    {
        Task<ErrorOr<List<GetMessagesResponseDTO>>> GetMsgsAsync(long chatId);
        Task<ErrorOr<long>> SendMsgAsync(SendMessageRequestDTO dto, long currentUserId);
        Task<ErrorOr<Success>> MarkMsgAsReadAsync(long messageId, long userId);
        Task<ErrorOr<Success>> MarkAllAsReadAsync(long currentUserId, long chatId);
        Task<ErrorOr<Success>> DeleteMsgAsync(long messageId, long userId, bool forEveryone = false);
    }
}
