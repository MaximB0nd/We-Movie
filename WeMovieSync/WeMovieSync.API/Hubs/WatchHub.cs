using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Runtime.CompilerServices;
using System.Security.Claims;
using WeMovieSync.Application.DTOs;
using WeMovieSync.Application.Interfaces;
using WeMovieSync.Application.Servives;

namespace WeMovieSync.API.Hubs
{
    [Authorize] 
    public class WatchHub : Hub
    {
        private readonly IChatService _chatService;
        private readonly IMsgService _msgService;

        public WatchHub(IChatService chatService, 
                        IMsgService msgService)
        {
            _chatService = chatService;
            _msgService = msgService;
        }

        // Получаем ID текущего пользователя из JWT
        private long GetUserId()
        {
            var userIdClaim = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !long.TryParse(userIdClaim, out var userId))
            {
                throw new HubException("Не удалось определить пользователя");
            }

            return userId;
        }

        /// <summary>
        /// Клиент присоединяется к комнате
        /// </summary>
        public async Task JoinRoom(long roomId)
        {
            var userId = GetUserId();

            // Проверяем, состоит ли пользователь в комнате
            if (!await _chatService.IsUserInRoomAsync(userId, roomId))
            {
                // Можно отправить ошибку клиенту
                await Clients.Caller.SendAsync("Error", "Вы не участник этой комнаты");
                return;
            }

            // Добавляем в группу SignalR (по roomId)
            string groupName = $"room_{roomId}";
            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

            // Отправляем текущему клиенту актуальное состояние плеера
            var stateResult = await _chatService.GetPlayerStateAsync(roomId);
            if (stateResult.IsError)
            {
                await Clients.Caller.SendAsync("Error", "Не удалось получить состояние комнаты");
                return;
            }

            await Clients.Caller.SendAsync("PlayerStateUpdated", stateResult.Value);

            // Уведомляем всех в комнате, что кто-то присоединился 
            await Clients.Group(groupName).SendAsync("MemberJoined", new RoomEventDTO
            {
                EventType = "joined",
                UserId = userId,
                Nickname = Context.User?.Identity?.Name ?? "Аноним"
            });
        }

        /// <summary>
        /// Клиент покидает комнату
        /// </summary>
        public async Task LeaveRoom(long roomId)
        {
            string groupName = $"room_{roomId}";
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);

            // Уведомляем остальных (опционально)
            await Clients.Group(groupName).SendAsync("MemberLeft", new RoomEventDTO
            {
                EventType = "left",
                UserId = GetUserId(),
                Nickname = Context.User?.Identity?.Name ?? "Аноним"
            });
        }

        /// <summary>
        /// Основной метод: любое действие с плеером
        /// </summary>
        public async Task SendPlayerAction(long roomId, PlayerActionDTO action)
        {
            var userId = GetUserId();

            // Пытаемся обновить состояние в БД
            var result = await _chatService.UpdatePlayerStateAsync(roomId, userId, action);

            if (result.IsError)
            {
                await Clients.Caller.SendAsync("Error", result.Errors.FirstOrDefault().Description ?? "Ошибка обновления плеера");
                return;
            }

            // Получаем актуальное состояние после обновления
            var stateResult = await _chatService.GetPlayerStateAsync(roomId);
            if (stateResult.IsError)
            {
                return;
            }

            // Рассылаем ВСЕМ в комнате
            string groupName = $"room_{roomId}";
            await Clients.Group(groupName).SendAsync("PlayerStateUpdated", stateResult.Value);
        }

        /// <summary>
        /// Отправка сообщения в чат (реал-тайм)
        /// </summary>
        public async Task SendChatMessage(SendMessageRequestDTO dto)
        {
            var userId = GetUserId();

            // Здесь можно добавить логику сохранения сообщения в БД через MsgService,
            // но для простоты сразу рассылаем
            await _msgService.SendMsgAsync(dto, userId);
            

            string groupName = $"room_{dto.RoomId}";
            await Clients.Group(groupName).SendAsync("ReceiveMessage", new
            {
                UserId = userId,
                Nickname = Context.User?.Identity?.Name ?? "Аноним",
                Text = dto.Text,
                SentAt = DateTime.UtcNow
            });
        }

        // При отключении клиента (закрыл приложение, потерял интернет)
        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            await base.OnDisconnectedAsync(exception);
        }
    }
}