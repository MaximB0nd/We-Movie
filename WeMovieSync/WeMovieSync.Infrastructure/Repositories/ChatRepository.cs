using WeMovieSync.Application.Interfaces;
using WeMovieSync.Core.Models;
using WeMovieSync.Infrastructure.Context;
using Microsoft.EntityFrameworkCore;

namespace WeMovieSync.Infrastructure.Repositories
{
    public class ChatRepository : IChatRepository
    {
        private readonly WeMovieSyncContext _context;

        public ChatRepository(WeMovieSyncContext context)
        {
            _context = context;
        }

        // Chats
        public async Task AddChatAsync(Chat chat)
        {
            await _context.Chats.AddAsync(chat);
            await _context.SaveChangesAsync();
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

        // Members
        public async Task<bool> IsUserInChatsAsync(long userId, long chatId)
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

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
