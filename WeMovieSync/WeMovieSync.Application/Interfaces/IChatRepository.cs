using WeMovieSync.Core.Models;

namespace WeMovieSync.Application.Interfaces
{
    public interface IChatRepository
    {
        // Chats
        Task<Chat?> GetByIdAsync(long chatId);
        Task AddChatAsync(Chat chat);
        Task DeleteChatAsync(long chatId);
        Task<List<Chat>> GetUserChatsAsync(long userId);
        Task<Chat> FindPrivateChatBetweenAsync(long userId, long otherId);



        // Members
        Task<bool> IsUserInChatsAsync(long userId, long chatId);
        Task AddMemberAsync(long chatId, long userId, string role = "member");
        Task RemoveMemberAsync(long chatId, long userId);

        Task SaveChangesAsync();
    }
}
