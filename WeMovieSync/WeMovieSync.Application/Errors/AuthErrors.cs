using ErrorOr;

namespace WeMovieSync.Application.Errors;

public static class AuthErrors
{
    public static Error EmailAlreadyExists =>
        Error.Conflict(
            code: "Auth.EmailAlreadyExists",
            description: "Email уже занят");

    public static Error InvalidCredentials =>
        Error.Unauthorized(
            code: "Auth.InvalidCredentials",
            description: "Неверный email или пароль");

    public static Error InvalidRefreshToken =>
        Error.Unauthorized(
            code: "Auth.InvalidRefreshToken",
            description: "Недействительный refresh token");

    public static Error UserNotFound =>
        Error.NotFound(
            code: "Auth.UserNotFound",
            description: "Пользователь не найден");
}
