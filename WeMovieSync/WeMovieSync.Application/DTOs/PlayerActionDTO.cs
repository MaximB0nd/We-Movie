namespace WeMovieSync.Application.DTOs
{
    public class PlayerActionDTO
    {
        /// <summary>
        /// Тип действия: "play", "pause", "seek", "rate", "changeFilm"
        /// </summary>
        public string Action { get; set; } = string.Empty;

        /// <summary>
        /// Позиция в секундах (для seek)
        /// </summary>
        public double? PositionSeconds { get; set; }

        /// <summary>
        /// Скорость воспроизведения
        /// </summary>
        public float? PlaybackRate { get; set; }

        /// <summary>
        /// Новый токен фильма (если меняем фильм)
        /// </summary>
        public long? NewFilmToken { get; set; }

        // Для совместимости со старым кодом (если был)
        public bool? IsPaused { get; set; }
    }
}