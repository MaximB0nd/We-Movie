using System;
using WeMovieSync.Core.Models;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ErrorOr;

namespace WeMovieSync.Application.Interfaces
{
    public interface IMessagesRepository
    {
        // Получить сообщения чата (пагинация по lastMsgId)
        Task<List<Message>> GetMsgsAsync(long chatId, long? lastMessageId, int limit = 30);

        // Отправить сообщение
        Task<Message> AddMsgAsync(long chatId, long senderId, string text);

        // Отметить сообщение как прочитанное (для конкретного пользователя)
        Task MarkAsReadAsync(long chatId, long userId, long messageId);

        // Удалить сообщение (для себя или для всех)
        Task DeleteMsgsAsync(long messageId, long userId, bool forEveryone = false);

        // Проверка сущестования сообщения
        Task<bool> IsMessageExistsAsync(long messageId);

        // Получение сообщения по Id
        Task<Message> GetMsgByIdAsync(long messageId);

        // Получение всех непрочитанных сообщений
        Task<List<long>> GetAllUnreadMsgsAsync(long chatId, long userId);


        // Сохранить изменения
        Task SaveChangesAsync();
    }
}
