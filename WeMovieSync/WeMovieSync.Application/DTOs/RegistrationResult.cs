namespace WeMovieSync.Application.DTOs
{
    public record RegistrationResult(
        string Nikname, 
        string Email
     );

    public record UserInfo(string Nickname, string Email);
}