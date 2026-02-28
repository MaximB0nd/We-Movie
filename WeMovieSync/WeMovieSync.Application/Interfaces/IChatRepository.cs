using WeMovieSync.Core.Models;

namespace WeMovieSync.Application.Interfaces
{
    public interface IChatRepository
    {
        Task<Chat?> GetByIdAsync(long chatId);
        Task<Chat?> GetWatchRoomByIdAsync(long chatId);

        Task AddChatAsync(Chat chat);
        Task UpdateChatAsync(Chat chat);
        Task DeleteChatAsync(long chatId);

        Task<List<Chat>> GetUserRoomsAsync(long userId);

        Task<bool> IsUserInRoomAsync(long userId, long roomId);

        Task AddMemberAsync(long roomId, long userId, string role = "member");
        Task RemoveMemberAsync(long roomId, long userId);

        Task UpdateWatchRoomStateAsync(
            long roomId,
            long? filmId,
            double positionSeconds,
            bool isPaused,
            float playbackRate);

        Task SetHostAsync(long roomId, long userId);

        Task SaveChangesAsync();
    }
}
