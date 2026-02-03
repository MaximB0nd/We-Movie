using WeMovieSync.Core.Models;


public class RefreshToken
{
    public long Id { get; set; } // PK
    public string HashedToken { get; set; } = null!;
    public long UserId { get; set; }
    public DateTime Expires { get; set; }
    public bool IsRevoked { get; set; }
    public DateTime? RevokedAt { get; set; }
    public string? ReplacedByToken { get; set; } // для ротации (опционально)
    public User? User { get; set; } // навигация
}