namespace WeMovieSync.Application.DTOs
{
    public class PlayerActionDTO
    {
        public double? PositionSeconds { get; set; }
        public bool? IsPaused { get; set; }
        public float? PlaybackRate { get; set; }
    }
}
