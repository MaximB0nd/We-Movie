using System.ComponentModel.DataAnnotations;

namespace WeMovieSync.Core.Models
{
    public class Chat
    {
        public long Id { get; set; }

        // public bool IsGroup { get; set; }

        [Required]
        public bool IsWatchRoom { get; set; } = true;

        [MaxLength(100)]
        public string? Name { get; set; } 

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? LastActivityAt { get; set; }  // обновлять при новом сообщении

        // Поля для комнаты просмотра 
        public long? CurrentFilmId { get; set; }  // привязка к фильму из каталога
        public DateTime? FilmStartedAt { get; set; }
        public double CurrentPositionSeconds { get; set; } = 0;
        public bool IsPaused { get; set; } = true;
        public float PlaybackRate { get; set; } = 1.0f;

        public long? HostUserId { get; set; }  // хозяин комнаты (кто может управлять плеером)


        // Навигация
        public ICollection<ChatMember> Members { get; set; } = new List<ChatMember>();
        public ICollection<Message> Messages { get; set; } = new List<Message>();
        public FilmCatalog? CurrentFilm { get; set; }
    }
}