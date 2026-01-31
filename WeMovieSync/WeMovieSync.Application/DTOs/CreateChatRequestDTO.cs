namespace WeMovieSync.Application.DTOs
{
    public class CreateChatRequestDTO
    {
        public long ChatName { get; set; }
        public bool IsGroup { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime LastActivityAt { get; set; } = DateTime.UtcNow;
        public List<long>? Members { get; set; }
    }
}
