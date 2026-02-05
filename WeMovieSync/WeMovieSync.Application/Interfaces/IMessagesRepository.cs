using System;
using WeMovieSync.Core.Models;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeMovieSync.Application.Interfaces
{
    public interface IMessagesRepository
    {
        // Получить сообщения чата (пагинация по lastMsgId)
        Task<List<Message>> GetMsgsAsync(long chatId, long? lastMessageId, int limit = 30);

        // Отправить сообщение
        Task<Message> AddMsgsAsync(long chatId, long senderId, string text);

        // Отметить сообщение как прочитанное (для конкретного пользователя)
        Task MarkAsReadAsync(long chatId, long userId, long messageId);

        // Удалить сообщение (для себя или для всех)
        Task DeleteMsgsAsync(long messageId, long userId, bool forEveryone = false);


        // Сохранить изменения
        Task SaveChangesAsync();
    }
}
