using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WeMovieSync.Application.DTOs;
using WeMovieSync.Application.Extensions;
using WeMovieSync.Application.Interfaces;
using WeMovieSync.Application.Services;
using WeMovieSync.Application.Servives;
using WeMovieSync.Core.Models;


namespace WeMovieSync.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MessageController : ControllerBase
    {
        private readonly IMsgService _msgService;

        public MessageController(IMsgService msgService)
        {
            _msgService = msgService;
        }

        // GET: последние сообщения чата
        [Authorize]
        [HttpGet("chats/{chatId}/messages")]
        public async Task<IActionResult> GetMessages(long chatId, long? lastMessageId = null)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _msgService.GetMsgsAsync(userId, chatId, lastMessageId);
                return result.ToActionResult();
            }
            catch (Exception ex)
            {
                // TODO: добавить логгер
                return StatusCode(500, "Internal server error");
            }
        }

        // POST: отправить сообщение
        [Authorize]
        [HttpPost("chats/{chatId}/messages")]
        public async Task<IActionResult> SendMessage(long chatId, [FromBody] SendMessageRequestDTO dto)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                dto.ChatId = chatId; // на всякий случай
                var result = await _msgService.SendMsgAsync(dto, userId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // PUT: отметить одно сообщение как прочитанное
        [Authorize]
        [HttpPut("messages/{messageId}/read")]
        public async Task<IActionResult> MarkMessageAsRead(long messageId)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _msgService.MarkMsgAsReadAsync(messageId, userId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // PUT: отметить все сообщения в чате как прочитанные
        [Authorize]
        [HttpPut("chats/{chatId}/read-all")]
        public async Task<IActionResult> MarkAllAsRead(long chatId)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _msgService.MarkAllAsReadAsync(userId, chatId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // DELETE: удалить сообщение
        [Authorize]
        [HttpDelete("messages/{messageId}")]
        public async Task<IActionResult> DeleteMessage(long messageId, [FromQuery] bool forAll = false)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _msgService.DeleteMsgAsync(messageId, userId, forAll);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
