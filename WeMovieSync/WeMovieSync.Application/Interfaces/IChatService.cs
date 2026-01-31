using WeMovieSync.Application.DTOs;
using ErrorOr;

namespace WeMovieSync.Application.Interfaces
{
    public interface IChatService
    {
        Task<ErrorOr<CreateChatResponceDTO>> GetUserChatsAsync(CreateChatRequestDTO dto);
        Task<ErrorOr<CreateChatResponceDTO>> CreateChatAsync(CreateChatRequestDTO dto);
        Task<object> DeleteChatAsync();
     }
}
