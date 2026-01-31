using ErrorOr;

namespace WeMovieSync.Application.Errors
{
    public static class CharErrors
    {
        public static Error ChatNotFound =>
            Error.NotFound(
                code: "Chat.ChatNotFound",
                description: "Чат не найден");

        public static Error UserNotInChat =>
            Error.Validation(
                code: "Chat.UserNotInChat",
                description: "Пользователь не состоит в чате");

        public static Error UserAlreadyInChat =>
            Error.Validation(
                code: "Chat.UserAlreadyInChat",
                description: "Пользователь уже состоит в чате");

        public static Error CannotDeleteChatWithOtherUsers =>
            Error.Validation(
                code: "Chat.CannotDeleteChatWithOtherUsers",
                description: "Невозможно удалить чат, в котором есть другие пользователи");
    }
}
