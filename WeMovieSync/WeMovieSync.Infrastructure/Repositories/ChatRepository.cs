using WeMovieSync.Application.Interfaces;
using WeMovieSync.Core.Models;
using WeMovieSync.Infrastructure.Context;
using Microsoft.EntityFrameworkCore;
using ErrorOr;

namespace WeMovieSync.Infrastructure.Repositories
{
    public class ChatRepository : IChatRepository
    {
        private readonly WeMovieSyncContext _context;

        public ChatRepository(WeMovieSyncContext context)
        {
            _context = context;
        }

        public async Task AddChatAsync(Chat chat)
        {
            await _context.Chats.AddAsync(chat);
        }

        public async Task<Chat?> GetWatchRoomByIdAsync(long chatId)
        {
            return await _context.Chats
                .Include(c => c.CurrentFilm)
                .Include(c => c.Members).ThenInclude(m => m.User)
                .Include(c => c.Messages.OrderByDescending(m => m.SentAt).Take(1))
                .FirstOrDefaultAsync(c => c.Id == chatId && c.IsWatchRoom);
        }

        public async Task DeleteChatAsync(long chatId)
        {
            var chat = await _context.Chats.FindAsync(chatId);
            if (chat != null)
            {
                _context.Chats.Remove(chat);
            }
        }

        public async Task<Chat?> GetByIdAsync(long chatId)
        {
            return await _context.Chats
                .Include(c => c.Members)
                .ThenInclude(m => m.User)
                .Include(c => c.Messages.OrderByDescending(m => m.SentAt).Take(1)) // последнее сообщение
                .FirstOrDefaultAsync(c => c.Id == chatId);
        }

        public async Task<List<Chat>> GetUserChatsAsync(long userId)
        {
           return await _context.Chats
                .Include(c => c.Members)
                .Where(c => c.Members.Any(m => m.UserId == userId))
                .OrderByDescending(c => c.LastActivityAt)
                .ToListAsync();
        }

        public async Task<bool> IsUserInRoomAsync(long userId, long roomId)
        {
            return await _context.ChatMembers
                .AnyAsync(cm => cm.ChatId == roomId && cm.UserId == userId);
        }

        public async Task<bool> IsUserInChatAsync(long userId, long chatId)
        {
            return await _context.ChatMembers
                .AnyAsync(cm => cm.ChatId == chatId && cm.UserId == userId);
        }

        public async Task AddMemberAsync(long chatId, long userId, string role)
        {
            var member = new ChatMember
            {
                ChatId = chatId,
                UserId = userId,
                Role = role
            };
            await _context.ChatMembers.AddAsync(member);
        }

        public async Task RemoveMemberAsync(long chatId, long userId)
        {
            var member = await _context.ChatMembers
                .FirstOrDefaultAsync(cm => cm.ChatId == chatId && cm.UserId != userId);

            if (member != null)
            {
                _context.ChatMembers.Remove(member);
            }
        }

        public async Task UpdateWatchRoomStateAsync(
         long roomId,
         long? filmId,
         double positionSeconds,
         bool isPaused,
         float playbackRate)
        {
            var room = await _context.Chats.FindAsync(roomId);
            if (room == null || !room.IsWatchRoom) return;

            room.CurrentFilmId = filmId;
            room.CurrentPositionSeconds = positionSeconds;
            room.IsPaused = isPaused;
            room.PlaybackRate = playbackRate;
            room.LastActivityAt = DateTime.UtcNow;

            _context.Chats.Update(room);
        }

        public async Task<List<Chat>> GetUserRoomsAsync(long userId)
        {
            return await _context.Chats
                .Include(c => c.Members)
                .Where(c => c.Members.Any(m => m.UserId == userId) && c.IsWatchRoom)
                .OrderByDescending(c => c.LastActivityAt)
                .ToListAsync();
        }

        public async Task SetHostAsync(long chatId, long userId)
        {
            var chat = await _context.Chats.FindAsync(chatId);
            if (chat == null || !chat.IsWatchRoom)
                return;

            chat.HostUserId = userId;
            _context.Chats.Update(chat);
        }

        public async Task UpdateChatAsync(Chat chat)
        {
            _context.Chats.Update(chat);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
