using ErrorOr;
using WeMovieSync.Application.DTOs;
using WeMovieSync.Application.Errors;
using WeMovieSync.Application.Interfaces;
using WeMovieSync.Core.Models;

namespace WeMovieSync.Application.Services
{
    public class ChatService : IChatService
    {
        private readonly IChatRepository _chatRepository;
        private readonly IUserRepository _userRepository; 

        public ChatService(IChatRepository chatRepository, IUserRepository userRepository)
        {
            _chatRepository = chatRepository;
            _userRepository = userRepository;
        }

        public async Task<ErrorOr<List<ChatPreviewDto>>> GetUserChatsAsync(long currentUserId)
        {
            var chats = await _chatRepository.GetUserChatsAsync(currentUserId);

            var dtos = chats.Select(c => new ChatPreviewDto
            {
                Id = c.Id,
                IsGroup = c.IsGroup,
                Name = c.IsGroup ? c.Name : null,

                // Последнее сообщение (берём самое новое)
                LastMessagePreview = c.Messages?
                    .OrderByDescending(m => m.SentAt)
                    .FirstOrDefault()?
                    .Text?
                    .Substring(0, Math.Min(100, c.Messages.FirstOrDefault()?.Text?.Length ?? 0)),

                LastMessageTime = c.Messages?
                    .OrderByDescending(m => m.SentAt)
                    .FirstOrDefault()?
                    .SentAt,

                UnreadCount = 0, // TODO: реализовать подсчёт непрочитанных (см. ниже)

                Members = c.Members.Select(m => new UserPreviewDto
                {
                    Id = m.UserId,
                    Nickname = m.User?.Nickname ?? "Пользователь",
                }).ToList()
            }).ToList();

            return dtos;
        }

        public async Task<ErrorOr<long>> CreatePrivateChatAsync(long currentUserId, long otherUserId)
        {
           if (currentUserId == otherUserId) {
                return ChatErrors.CannotCreateChatWithSelf;
           }

            var existingChat = await _chatRepository.FindPrivateChatBetweenAsync(currentUserId, otherUserId);
            if (existingChat != null) {
                return existingChat.Id;
            }

            var chat = new Chat
            {
                IsGroup = false,
                CreatedAt = DateTime.UtcNow,
                LastActivityAt = DateTime.UtcNow
            };

            await _chatRepository.AddChatAsync(chat);

            await _chatRepository.AddMemberAsync(chat.Id, currentUserId, "member");
            await _chatRepository.AddMemberAsync(chat.Id, otherUserId, "member");

            await _chatRepository.SaveChangesAsync();

            return chat.Id;
        }

        public async Task<ErrorOr<long>> CreateGroupChatAsync(long creatorId, string name, List<long> initialMemberIds)
        {
            if (string.IsNullOrWhiteSpace(name))
                return ChatErrors.GroupNameRequired;

            if (!initialMemberIds.Any())
                return ChatErrors.GroupMustHaveMembers;

            // Проверяем, что все пользователи существуют
            foreach (var userId in initialMemberIds)
            {
                var user = await _userRepository.GetByIdAsync(userId);
                if (user == null)
                    return Error.NotFound($"Пользователь {userId} не найден");
            }

            var chat = new Chat
            {
                IsGroup = true,
                Name = name,
                CreatedAt = DateTime.UtcNow,
                LastActivityAt = DateTime.UtcNow
            };

            await _chatRepository.AddChatAsync(chat);

            // Добавляем создателя как админа
            await _chatRepository.AddMemberAsync(chat.Id, creatorId, "admin");

            // Добавляем остальных
            foreach (var userId in initialMemberIds)
            {
                await _chatRepository.AddMemberAsync(chat.Id, userId, "member");
            }

            await _chatRepository.SaveChangesAsync();

            return chat.Id;
        }

        public async Task<ErrorOr<Success>> DeleteChatAsync(long currentUserId, long chatId)
        {
            var chat = await _chatRepository.GetByIdAsync(chatId);
            if (chat == null)
                return ChatErrors.ChatNotFound;

            var member = chat.Members.FirstOrDefault(m => m.UserId == currentUserId);
            if (member == null)
                return ChatErrors.UserNotInChat;

            // Только админ может удалять
            if (member.Role != "admin")
                return Error.Forbidden("Только администратор может удалить чат");

            await _chatRepository.DeleteChatAsync(chatId);
            await _chatRepository.SaveChangesAsync();

            return Result.Success;
        }

        public async Task<ErrorOr<Success>> AddMemberAsync(long currentUserId, long chatId, long userIdToAdd)
        {
            var chat = await _chatRepository.GetByIdAsync(chatId);
            if (chat == null)
                return ChatErrors.ChatNotFound;

            if (!chat.IsGroup)
                return Error.Validation("Нельзя добавлять участников в приватный чат");

            var currentMember = chat.Members.FirstOrDefault(m => m.UserId == currentUserId);
            if (currentMember == null || currentMember.Role != "admin")
                return Error.Forbidden("Только администратор может добавлять участников");

            if (chat.Members.Any(m => m.UserId == userIdToAdd))
                return ChatErrors.UserAlreadyInChat;

            var userToAdd = await _userRepository.GetByIdAsync(userIdToAdd);
            if (userToAdd == null)
                return AuthErrors.UserNotFound;

            await _chatRepository.AddMemberAsync(chatId, userIdToAdd, "member");
            await _chatRepository.SaveChangesAsync();

            return Result.Success;
        }

        public async Task<ErrorOr<Success>> RemoveMemberAsync(long currentUserId, long chatId, long userIdToRemove)
        {
            var chat = await _chatRepository.GetByIdAsync(chatId);
            if (chat == null)
                return ChatErrors.ChatNotFound;

            if (!chat.IsGroup)
                return Error.Validation("Нельзя удалять участников из приватного чата");

            var currentMember = chat.Members.FirstOrDefault(m => m.UserId == currentUserId);
            if (currentMember == null || currentMember.Role != "admin")
                return Error.Forbidden("Только администратор может удалять участников");

            if (!chat.Members.Any(m => m.UserId == userIdToRemove))
                return ChatErrors.UserNotInChat;

            await _chatRepository.RemoveMemberAsync(chatId, userIdToRemove);
            await _chatRepository.SaveChangesAsync();


            return Result.Success;
        }
    }
}