namespace WeMovieSync.Application.DTOs
{
    public class SendMessageRequestDTO
    {
        public long RoomId { get; set; }
        public string Text { get; set; } = string.Empty;
    }
}
