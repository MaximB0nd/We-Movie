namespace WeMovieSync.Application.DTOs
{
    public record AuthResponse(
         string AccessToken,
         string RefreshToken,
         int ExpiresIn,
         UserInfo User
     );
}
