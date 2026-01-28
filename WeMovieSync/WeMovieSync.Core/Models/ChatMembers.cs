namespace WeMovieSync.Core.Models
{
    public class ChatMember
    {
        public long ChatId { get; set; }
        public long UserId { get; set; }
        public DateTime JoinedAt { get; set; }
        public string Role { get; set; } = "member";

        public User? User { get; set; }
        public Chat? Chats { get; set; }
    }
}
