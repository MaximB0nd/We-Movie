
namespace WeMovieSync.Application.Interfaces
{
    public interface IChatService
    {
        Task<object> GetUserChatsAsync();
        Task<object> CreateChatAsync();
        Task<object> DeleteChatAsync();
     }
}
