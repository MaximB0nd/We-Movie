using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using WeMovieSync.Application.Interfaces;
using WeMovieSync.Core.Models;
using WeMovieSync.Infrastructure.Context;

namespace WeMovieSync.Infrastructure.Repositories
{
    public class MessageRepository : IMessagesRepository
    {
        private readonly WeMovieSyncContext _context;

        public MessageRepository(WeMovieSyncContext context)
        {
            _context = context;
        }

        // Getting list of last (limit gives lenght) msgs in chat from lastMessageId 
        public async Task<List<Message>> GetMsgsAsync(long chatId, long? lastMessageId, int limit)
        {
            var query = _context.Messages
                .Include(m => m.Sender)  // отправитель
                .Where(m => m.ChatId == chatId);

            if (lastMessageId.HasValue)
            {
                query = query.Where(m => m.Id < lastMessageId.Value); 
            }

            return await query
                .OrderByDescending(m => m.SentAt)
                .Take(limit)
                .ToListAsync();
        }

        // Adding new msg to DB
        public async Task<Message> AddMsgsAsync(long chatId, long senderId, string text)
        {
            var message = new Message
            {
                ChatId = chatId,
                SenderId = senderId,
                Text = text,
                SentAt = DateTime.UtcNow,
                DeliveredAt = DateTime.UtcNow 
            };

            await _context.Messages.AddAsync(message);
            return message; 
        }

        // Marks msg read for chosen user
        public async Task MarkAsReadAsync(long chatId, long userId, long messageId)
        {
            var messageExists = await _context.Messages.AnyAsync(m => m.Id == messageId);
            if (!messageExists)
                return; 

            var existingRead = await _context.MessagesReads
                .FirstOrDefaultAsync(r => r.MessageId == messageId && r.UserId == userId);

            if (existingRead != null)
                return; 

            var read = new MessageRead
            {
                MessageId = messageId,
                UserId = userId,
                ReadAt = DateTime.UtcNow
            };

            await _context.MessagesReads.AddAsync(read);
        }

        // Deleting msg (for all || only for one user)
        public async Task DeleteMsgsAsync(long messageId, long userId, bool forEveryone = false)
        {
            var message = await _context.Messages
                .Include(m => m.Sender)
                .FirstOrDefaultAsync(m => m.Id == messageId);

            _context.Messages.Remove(message);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}

