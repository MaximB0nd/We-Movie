namespace WeMovieSync.Application.DTOs
{
    public class PlayerStateDTO
    {
        public long RoomId { get; set; }
        public long? CurrentFilmId { get; set; }
        public string? FilmName { get; set; }
        public double CurrentPositionSeconds { get; set; }
        public bool IsPaused { get; set; }
        public float PlaybackRate { get; set; }
        public long? HostUserId { get; set; }
    }
}
