using SocialCoreService.Models;

public class RefreshToken
{
    public int Id { get; set; } // PK
    public string Token { get; set; } // уникальный, длинный (64+ символа)
    public int UserId { get; set; }
    public DateTime Expires { get; set; }
    public bool IsRevoked { get; set; }
    public DateTime? RevokedAt { get; set; }
    public string? ReplacedByToken { get; set; } // для ротации (опционально)
    public Users User { get; set; } // навигация
}