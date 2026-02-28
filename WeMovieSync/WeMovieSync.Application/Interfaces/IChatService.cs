using WeMovieSync.Application.DTOs;
using ErrorOr;

namespace WeMovieSync.Application.Interfaces
{
    public interface IChatService
    {
        // СТАРЫЕ МЕТОДЫ
        // Получить чаты текущего пользователя (с preview)
        Task<ErrorOr<List<ChatPreviewDto>>> GetUserChatsAsync(long currentUserId);

        // Удалить чат (только если админ или участник)
        Task<ErrorOr<Success>> DeleteChatAsync(long currentUserId, long chatId);

        // Добавить участника в групповой чат (только админ)
        Task<ErrorOr<Success>> AddMemberAsync(long currentUserId, long chatId, long userIdToAdd);

        // Удалить участника из группового чата (только админ)
        Task<ErrorOr<Success>> RemoveMemberAsync(long currentUserId, long chatId, long userIdToRemove);

        // НОВЫЕ МЕТОДЫ
        Task<ErrorOr<long>> CreateWatchRoomAsync(long creatorId, long filmId, string? roomName = null);
        Task<ErrorOr<Success>> UpdatePlayerStateAsync(long roomId, long userId, PlayerActionDTO action);
        Task<ErrorOr<PlayerStateDTO>> GetPlayerStateAsync(long roomId);

        // Назначение модератора
        Task<ErrorOr<Success>> GrantModeratorRoleAsync(long currentUserId, long roomId, long targetUserId);
        Task<ErrorOr<Success>> RevokeModeratorRoleAsync(long currentUserId, long roomId, long targetUserId);
    }
}
