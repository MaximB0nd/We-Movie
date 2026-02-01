using Microsoft.AspNetCore.Mvc;
using WeMovieSync.API.Extensions;
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



    }
}
