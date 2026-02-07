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
        private readonly MsgService _msgService;

        public MessageController(MsgService msgService)
        {
            _msgService = msgService;
        }

        // GET: get all messages of choosen chat
        [Authorize]
        [HttpGet("messages/{chatId}/{lastMessageId}")]
        public async Task<IActionResult> GetMessages(long chatId, long? lastMessageId)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _msgService.GetMsgsAsync(userId, chatId, lastMessageId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // HOST: add message to DB and sync to all users by web socket
        [Authorize]
        [HttpPost("addMessage")]
        public async Task<IActionResult> AddMessage([FromBody] SendMessageRequestDTO dto)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _msgService.SendMsgAsync(dto, userId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

    }
}
