using System;
using ErrorOr;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeMovieSync.Application.Errors
{
    public static class MessagesErrors
    {
        // Сообщение не найдено (самая частая)
        public static Error MessageNotFound =>
            Error.NotFound(
                code: "Message.MessageNotFound",
                description: "Сообщение не найдено");

        // Нет прав на действие
        public static Error ForbiddenToEdit =>
            Error.Forbidden(
                code: "Message.ForbiddenToEdit",
                description: "Редактировать можно только свои сообщения");

        public static Error ForbiddenToDelete =>
            Error.Forbidden(
                code: "Message.ForbiddenToDelete",
                description: "Удалять можно только свои сообщения");

        public static Error ForbiddenToDeleteForEveryone =>
            Error.Forbidden(
                code: "Message.ForbiddenToDeleteForEveryone",
                description: "Удаление для всех доступно только администратору чата");

        // Сообщение уже удалено / недоступно
        public static Error MessageAlreadyDeleted =>
            Error.Conflict(
                code: "Message.MessageAlreadyDeleted",
                description: "Сообщение уже удалено");

        // Пустое или некорректное сообщение
        public static Error EmptyMessageText =>
            Error.Validation(
                code: "Message.EmptyText",
                description: "Текст сообщения не может быть пустым");

        public static Error MessageTooLong =>
            Error.Validation(
                code: "Message.TextTooLong",
                description: "Сообщение слишком длинное (максимум 4096 символов)");

        // Пользователь не в чате
        public static Error UserNotInChat =>
            Error.Validation(
                code: "Chat.UserNotInChat",
                description: "Вы не состоите в этом чате");

        // Чат не найден (часто при отправке/чтении)
        public static Error ChatNotFound =>
            Error.NotFound(
                code: "Chat.ChatNotFound",
                description: "Чат не найден");

        // Ошибка при чтении (редко, но полезно)
        public static Error MessageAlreadyRead =>
            Error.Conflict(
                code: "Message.AlreadyRead",
                description: "Сообщение уже отмечено как прочитанное");
    }
}
 
