using WeMovieSync.Application.DTOs;
using ErrorOr;

namespace WeMovieSync.Application.Interfaces
{
    public interface IChatService
    {
        // Получить чаты текущего пользователя (с preview)
        Task<ErrorOr<List<ChatPreviewDto>>> GetUserChatsAsync(long currentUserId);

        // Создать приватный чат (1:1) — если уже есть, вернуть существующий
        Task<ErrorOr<long>> CreatePrivateChatAsync(long currentUserId, long otherUserId);

        // Создать групповой чат
        Task<ErrorOr<long>> CreateGroupChatAsync(long creatorId, string name, List<long> initialMemberIds);

        // Удалить чат (только если админ или участник)
        Task<ErrorOr<Success>> DeleteChatAsync(long currentUserId, long chatId);

        // Добавить участника в групповой чат (только админ)
        Task<ErrorOr<Success>> AddMemberAsync(long currentUserId, long chatId, long userIdToAdd);

        // Удалить участника из группового чата (только админ)
        Task<ErrorOr<Success>> RemoveMemberAsync(long currentUserId, long chatId, long userIdToRemove);
    }
}
