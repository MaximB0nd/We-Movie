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
        private readonly IFilmCatalogRepository _filmCatalogRepository;

        public ChatService(
            IChatRepository chatRepository,
            IUserRepository userRepository,
            IFilmCatalogRepository filmCatalogRepository)
        {
            _chatRepository = chatRepository;
            _userRepository = userRepository;
            _filmCatalogRepository = filmCatalogRepository;
        }

        // Получить список комнат текущего пользователя
        public async Task<ErrorOr<List<ChatPreviewDto>>> GetUserChatsAsync(long currentUserId)
        {
            var rooms = await _chatRepository.GetUserRoomsAsync(currentUserId);

            var dtos = rooms.Select(r => new ChatPreviewDto
            {
                Id = r.Id,
                Name = r.Name,
                LastMessagePreview = r.Messages?
                    .OrderByDescending(m => m.SentAt)
                    .FirstOrDefault()?
                    .Text?
                    .Substring(0, Math.Min(100, r.Messages.FirstOrDefault()?.Text?.Length ?? 0)),
                LastMessageTime = r.Messages?
                    .OrderByDescending(m => m.SentAt)
                    .FirstOrDefault()?
                    .SentAt,
                UnreadCount = 0, // TODO: реализовать позже
                Members = r.Members.Select(m => new UserPreviewDto
                {
                    Id = m.UserId,
                    Nickname = m.User?.Nickname ?? "Аноним"
                }).ToList()
            }).ToList();

            return dtos;
        }

        // Создать новую комнату просмотра
        public async Task<ErrorOr<long>> CreateWatchRoomAsync(long creatorId, long filmId, string? roomName = null)
        {
            var filmResult = await _filmCatalogRepository.GetFilmObjectByIdAsync(filmId);
            if (filmResult.IsError)
                return filmResult.Errors;

            var film = filmResult.Value;

            var room = new Chat
            {
                IsWatchRoom = true,
                Name = roomName ?? film.FilmName,
                HostUserId = creatorId,
                CurrentFilmId = filmId,
                CurrentPositionSeconds = 0,
                IsPaused = true,
                PlaybackRate = 1.0f,
                CreatedAt = DateTime.UtcNow,
                LastActivityAt = DateTime.UtcNow
            };

            await _chatRepository.AddChatAsync(room);
            await _chatRepository.AddMemberAsync(room.Id, creatorId, "host");
            await _chatRepository.SaveChangesAsync();

            return room.Id;
        }

        // Удалить комнату (только host или moderator)
        public async Task<ErrorOr<Success>> DeleteChatAsync(long currentUserId, long roomId)
        {
            var room = await _chatRepository.GetByIdAsync(roomId);
            if (room == null || !room.IsWatchRoom)
            {
                return ChatErrors.ChatNotFound;
            }

            var member = room.Members.FirstOrDefault(m => m.UserId == currentUserId);
            if (member == null)
            {
                return ChatErrors.UserNotInChat;
            }

            if (!IsHostOrModerator(member.Role)) { 
                return Error.Forbidden("Только хозяин или модератор может удалить комнату");
            }

            await _chatRepository.DeleteChatAsync(roomId);
            await _chatRepository.SaveChangesAsync();

            return Result.Success;
        }

        // Добавить участника (только host или moderator)
        public async Task<ErrorOr<Success>> AddMemberAsync(long currentUserId, long roomId, long userIdToAdd)
        {
            var room = await _chatRepository.GetByIdAsync(roomId);
            if (room == null || !room.IsWatchRoom)
            {
                return ChatErrors.ChatNotFound;
            }

            var currentMember = room.Members.FirstOrDefault(m => m.UserId == currentUserId);
            if (currentMember == null) { 
                return ChatErrors.UserNotInChat;
            }

            if (!IsHostOrModerator(currentMember.Role))
            {
                return Error.Forbidden("Нет прав добавлять участников");
            }

            if (room.Members.Any(m => m.UserId == userIdToAdd))
            {
                return ChatErrors.UserAlreadyInChat;
            }

            var user = await _userRepository.GetByIdAsync(userIdToAdd);
            if (user == null)
            {
                return AuthErrors.UserNotFound;
            }

            await _chatRepository.AddMemberAsync(roomId, userIdToAdd, "member");
            await _chatRepository.SaveChangesAsync();

            return Result.Success;
        }

        // Удалить участника (только host или moderator)
        public async Task<ErrorOr<Success>> RemoveMemberAsync(long currentUserId, long roomId, long userIdToRemove)
        {
            var room = await _chatRepository.GetByIdAsync(roomId);
            if (room == null || !room.IsWatchRoom)
            {
                return ChatErrors.ChatNotFound;
            }

            var currentMember = room.Members.FirstOrDefault(m => m.UserId == currentUserId);
            if (currentMember == null)
            {
                return ChatErrors.UserNotInChat;
            }

            if (!IsHostOrModerator(currentMember.Role))
            {
                return Error.Forbidden("Нет прав удалять участников");
            }

            if (!room.Members.Any(m => m.UserId == userIdToRemove))
            {
                return ChatErrors.UserNotInChat;
            }

            // Нельзя удалить самого себя
            if (userIdToRemove == currentUserId)
            {
                return Error.Validation("Нельзя удалить самого себя");
            }

            await _chatRepository.RemoveMemberAsync(roomId, userIdToRemove);
            await _chatRepository.SaveChangesAsync();

            return Result.Success;
        }

        // Обновить состояние плеера (только host или moderator)
        public async Task<ErrorOr<Success>> UpdatePlayerStateAsync(long roomId, long userId, PlayerActionDTO action)
        {
            var room = await _chatRepository.GetByIdAsync(roomId);
            if (room == null || !room.IsWatchRoom)
            {
                return ChatErrors.ChatNotFound;
            }

            var member = room.Members.FirstOrDefault(m => m.UserId == userId);
            if (member == null)
            {
                return ChatErrors.UserNotInChat;
            }

            if (!IsHostOrModerator(member.Role))
            {
                return Error.Forbidden("Нет прав управлять воспроизведением");
            }

            if (action.PositionSeconds.HasValue)
            {
                room.CurrentPositionSeconds = action.PositionSeconds.Value;
            }

            if (action.IsPaused.HasValue)
            {
                room.IsPaused = action.IsPaused.Value;
            }

            if (action.PlaybackRate.HasValue)
            {
                room.PlaybackRate = action.PlaybackRate.Value;
            }

            room.LastActivityAt = DateTime.UtcNow;

            _chatRepository.UpdateChatAsync(room);
            await _chatRepository.SaveChangesAsync();

            return Result.Success;
        }

        // Получить текущее состояние плеера (доступно всем участникам комнаты)
        public async Task<ErrorOr<PlayerStateDTO>> GetPlayerStateAsync(long roomId)
        {
            var room = await _chatRepository.GetWatchRoomByIdAsync(roomId);
            if (room == null || !room.IsWatchRoom)
                return ChatErrors.ChatNotFound;

            return new PlayerStateDTO
            {
                RoomId = roomId,
                CurrentFilmId = room.CurrentFilmId,
                FilmName = room.CurrentFilm?.FilmName,
                CurrentPositionSeconds = room.CurrentPositionSeconds,
                IsPaused = room.IsPaused,
                PlaybackRate = room.PlaybackRate,
                HostUserId = room.HostUserId
            };
        }

        // Назначить модератора (только host)
        public async Task<ErrorOr<Success>> GrantModeratorRoleAsync(long currentUserId, long roomId, long targetUserId)
        {
            var room = await _chatRepository.GetByIdAsync(roomId);
            if (room == null || !room.IsWatchRoom)
                return ChatErrors.ChatNotFound;

            var currentMember = room.Members.FirstOrDefault(m => m.UserId == currentUserId);
            if (currentMember == null)
                return ChatErrors.UserNotInChat;

            if (currentMember.Role != "host")
                return Error.Forbidden("Только хозяин комнаты может назначать модераторов");

            var targetMember = room.Members.FirstOrDefault(m => m.UserId == targetUserId);
            if (targetMember == null)
                return ChatErrors.UserNotInChat;

            if (targetMember.Role == "host")
                return Error.Validation("Хозяин комнаты не может быть модератором");

            targetMember.Role = "moderator";

            _chatRepository.UpdateChatAsync(room);
            await _chatRepository.SaveChangesAsync();

            return Result.Success;
        }

        // Снять модератора (только host)
        public async Task<ErrorOr<Success>> RevokeModeratorRoleAsync(long currentUserId, long roomId, long targetUserId)
        {
            var room = await _chatRepository.GetByIdAsync(roomId);
            if (room == null || !room.IsWatchRoom)
                return ChatErrors.ChatNotFound;

            var currentMember = room.Members.FirstOrDefault(m => m.UserId == currentUserId);
            if (currentMember == null)
                return ChatErrors.UserNotInChat;

            if (currentMember.Role != "host")
                return Error.Forbidden("Только хозяин комнаты может снимать модераторов");

            var targetMember = room.Members.FirstOrDefault(m => m.UserId == targetUserId);
            if (targetMember == null)
                return ChatErrors.UserNotInChat;

            if (targetMember.Role != "moderator")
                return Error.Validation("Пользователь не является модератором");

            targetMember.Role = "member";

            _chatRepository.UpdateChatAsync(room);
            await _chatRepository.SaveChangesAsync();

            return Result.Success;
        }

        // Вспомогательный метод для проверки прав
        private static bool IsHostOrModerator(string role)
        {
            return role == "host" || role == "moderator";
        }
    }
}