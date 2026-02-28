using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WeMovieSync.Application.DTOs;
using WeMovieSync.Application.Extensions;
using WeMovieSync.Application.Interfaces;   


namespace WeMovieSync.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatController : ControllerBase
    {
        private readonly IChatService _chatService;

        public ChatController(IChatService chatService)
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


        
        // POST: creating group chat
        [Authorize]
        [HttpPost("room")]
        public async Task<IActionResult> CreateRoom([FromBody] CreateRoomRequestDTO dto)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.CreateWatchRoomAsync(userId, dto.token, dto.Name);
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

        // GET: get state of room
        [Authorize]
        [HttpGet("rooms/{roomId}/player-state")]
        public async Task<IActionResult> GetPlayerState(long roomId)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.GetPlayerStateAsync(roomId);
                if (result.IsError)
                {
                    return result.ToActionResult();
                }

                return Ok(result.Value);
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // PUT: update player state
        [Authorize]
        [HttpPut("rooms/{roomId}/player-state")]
        public async Task<IActionResult> UpdatePlayerState(long roomId, [FromBody] PlayerActionDTO action)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.UpdatePlayerStateAsync(roomId, userId, action);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // PUT: make user moderator of room
        [Authorize]
        [HttpPut("rooms/{roomId}/grant-moderator")]
        public async Task<IActionResult> GrantModerator(long roomId, [FromBody] ModeratorActionDTO dto)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.GrantModeratorRoleAsync(userId, roomId, dto.UserId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }

        // PUT: revoke moderator role
        [Authorize]
        [HttpPut("rooms/{roomId}/revoke-moderator")]
        public async Task<IActionResult> RevokeModerator(long roomId, [FromBody] ModeratorActionDTO dto)
        {
            try
            {
                var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var result = await _chatService.RevokeModeratorRoleAsync(userId, roomId, dto.UserId);
                return result.ToActionResult();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
