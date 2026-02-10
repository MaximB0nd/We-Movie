using ErrorOr;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WeMovieSync.Application.DTOs;
using WeMovieSync.Application.Errors;
using WeMovieSync.Application.Interfaces;
using WeMovieSync.Core.Models;

namespace WeMovieSync.Application.Services
{
    public class MsgService : IMsgService
    {
        private readonly IMessagesRepository _messageRepository;
        private readonly IUserRepository _userRepository;
        private readonly IChatRepository _chatRepository;

        public MsgService(IMessagesRepository messagesRepository, IUserRepository userRepository, IChatRepository chatRepository)
        {
            _messageRepository = messagesRepository;
            _userRepository = userRepository;
            _chatRepository = chatRepository;
        }

        public async Task<ErrorOr<List<GetMessagesResponseDTO>>> GetMsgsAsync(
            long currentUserId,
            long chatId,
            long? lastMessageId = null)
        {
            int limit = 20;

            if (!await _chatRepository.IsUserInChatAsync(currentUserId, chatId))
            {
                return ChatErrors.UserNotInChat;
            }

            var messages = await _messageRepository.GetMsgsAsync(chatId, lastMessageId, limit);

            var dtos = messages.Select(m => new GetMessagesResponseDTO
            {
                MessageId = m.Id,
                SenderId = m.SenderId,
                SenderNickname = m.Sender?.Nickname ?? "Пользователь",
                ChatId = m.ChatId,
                Text = m.Text,
                SentAt = m.SentAt,
                DeliveredAt = m.DeliveredAt,
                IsReadByCurrentUser = m.Reads?.Any(r => r.UserId == currentUserId) ?? false
            }).ToList();

            return dtos;
        }

        public async Task<ErrorOr<long>> SendMsgAsync(SendMessageRequestDTO dto, long currentUserId)
        {
            // Валидация
            if (string.IsNullOrWhiteSpace(dto.Text))
            {
                return MessagesErrors.EmptyMessageText;
            }

            // Checking access to chat
            if (!await _chatRepository.IsUserInChatAsync(currentUserId, dto.ChatId))
            {
                return ChatErrors.UserNotInChat;
            }

            var message = await _messageRepository.AddMsgAsync(
                chatId: dto.ChatId,
                senderId: currentUserId,
                text: dto.Text
            );

            await _messageRepository.SaveChangesAsync();

            // TODO: Отправка через SignalR
            // await _hubContext.Clients.Group($"chat_{dto.ChatId}").SendAsync("ReceiveMessage", message);

            return message.Id; 
        }

        public async Task<ErrorOr<Success>> MarkMsgAsReadAsync(long messageId, long userId)
        {
            var message = await _messageRepository.GetMsgByIdAsync(messageId);

            if (message == null) {
                return MessagesErrors.MessageNotFound;
            }

            var isInChat = await _chatRepository.IsUserInChatAsync(userId, message.ChatId);
            if (!isInChat)
            {
                return ChatErrors.UserNotInChat;
            }

            await _messageRepository.MarkAsReadAsync(message.ChatId, messageId, userId);
            await _messageRepository.SaveChangesAsync();

            return Result.Success;
        }

        public async Task<ErrorOr<Success>> MarkAllAsReadAsync(long currentUserId, long chatId)
        {
            // Проверка доступа к чату
            if (!await _chatRepository.IsUserInChatAsync(currentUserId, chatId))
                return ChatErrors.UserNotInChat;

            // Получаем все непрочитанные сообщения
            var unreadMessages = await _messageRepository.GetAllUnreadMsgsAsync(chatId, currentUserId);

            foreach (var msgId in unreadMessages)
            {
                var message = await _messageRepository.GetMsgByIdAsync(msgId);
                await _messageRepository.MarkAsReadAsync(message.ChatId,msgId, currentUserId);
            }

            await _messageRepository.SaveChangesAsync();

            return Result.Success;
        }

        public async Task<ErrorOr<Success>> DeleteMsgAsync(long messageId, long userId, bool forEveryone = false)
        {
            var message = await _messageRepository.GetMsgByIdAsync(messageId);
            if (message == null)
            {
                return MessagesErrors.MessageNotFound;
            }

            // Проверка доступа к чату
            if (!await _chatRepository.IsUserInChatAsync(userId, message.ChatId))
            {
                return ChatErrors.UserNotInChat;
            }

            // Проверка прав на удаление
            if (message.SenderId != userId)
            {
                if (!forEveryone)
                {
                    return MessagesErrors.ForbiddenToDelete;
                }

                // forEveryone — только админ (добавь позже проверку роли)
                return Error.Forbidden("Удаление для всех пока недоступно");
            }

            await _messageRepository.DeleteMsgsAsync(messageId, userId, forEveryone);
            await _messageRepository.SaveChangesAsync();

            return Result.Success;
        }
    }
}
