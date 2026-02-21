using ErrorOr;

namespace WeMovieSync.Application.Errors;

public static class AuthErrors
{
    public static Error EmailAlreadyExists =>
        Error.Conflict(
            code: "Auth.EmailAlreadyExists",
            description: "Email уже занят");

    public static Error NickAlreadyExists =>
        Error.Conflict(
            code: "Auth.NickAlreadyExists",
            description: "Nick уже занят");

    public static Error InvalidCredentials =>
        Error.Unauthorized(
            code: "Auth.InvalidCredentials",
            description: "Неверный email/nick или пароль");

    public static Error InvalidRefreshToken =>
        Error.Unauthorized(
            code: "Auth.InvalidRefreshToken",
            description: "Недействительный refresh token");

    public static Error UserNotFound =>
        Error.NotFound(
            code: "Auth.UserNotFound",
            description: "Пользователь не найден");
}
