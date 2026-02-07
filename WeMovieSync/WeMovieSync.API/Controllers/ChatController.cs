using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WeMovieSync.Application.Extensions;
using WeMovieSync.Application.DTOs;
using WeMovieSync.Application.Services;


namespace WeMovieSync.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatController : ControllerBase
    {
        private readonly ChatService _chatService;

        public ChatController(ChatService chatService)
        {
            _chatService = chatService;
        }

        // GET: getting all chats of user
        [Authorize]
        [HttpGet("chats")]
        public async Task<IActionResult> GetUserChats()
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.GetUserChatsAsync(userId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }


        // POST: creating private chat between two users
        [Authorize]
        [HttpPost("private")]
        public async Task<IActionResult> CreatePrivatChat([FromBody] CreatePrivateChatRequistDTO dto)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.CreatePrivateChatAsync(userId, dto.OtherUserId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // POST: creating group chat
        [Authorize]
        [HttpPost("group")]
        public async Task<IActionResult> CreateGroupChat([FromBody] CreateGroupChatRequestDTO dto)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.CreateGroupChatAsync(userId, dto.Name, dto.InitialMemberIds);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // DELETE : deleting chat by id
        [Authorize]
        [HttpDelete("{chatId}")]
        public async Task<IActionResult> DeleteChat(long chatId)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.DeleteChatAsync(userId, chatId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // PUT: add member to group chat
        [Authorize]
        [HttpPut("{chatId}/add-member")]
        public async Task<IActionResult> AddMemberToGroupChat(long chatId, [FromBody] AddMemberRequestDTO dto)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.AddMemberAsync(userId, chatId, dto.UserId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // PUT: remove member from group chat
        [Authorize]
        [HttpPut("{chatId}/remove-member")]
        public async Task<IActionResult> RemoveMember(long chatId, [FromBody] RemoveMemberRequestDTO dto)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.RemoveMemberAsync(userId, chatId, dto.UserId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
