namespace WeMovieSync.Application.DTOs
{
    public class ChatPreviewDto
    {
        public long Id { get; set; }
        public bool IsGroup { get; set; }
        public string? Name { get; set; }
        public string? LastMessagePreview { get; set; }   
        public DateTime? LastMessageTime { get; set; }     
        public int UnreadCount { get; set; }               
        public List<UserPreviewDto> Members { get; set; } = new();
    }

    public class UserPreviewDto
    {
        public long Id { get; set; }
        public string? Nickname { get; set; }
    }
}
