namespace WeMovieSync.Application.DTOs
{
    public class RoomEventDTO
    {
        public string EventType { get; set; } = string.Empty; // "joined", "left", "role_changed"
        public long UserId { get; set; }
        public string? Nickname { get; set; }
        public string? NewRole { get; set; } // только для role_changed
    }
}
