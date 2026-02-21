using ErrorOr;

namespace WeMovieSync.Application.Errors
{
    public static class ChatErrors
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

        public static Error CannotCreateChatWithSelf =>
            Error.Validation(
                code: "Chat.CannotCreateChatWithSelf",
                description: "Нельзя создать чат с самим собой");

        public static Error GroupNameRequired =>
            Error.Validation(
                code: "Chat.GroupNameRequired",
                description: "Имя группы обязательно!");

        public static Error GroupMustHaveMembers =>
            Error.Validation(
                code: "Chat.GroupMustHaveMembers",
                description: "В группе должно быть минимум 3 участника!");
    }
}
