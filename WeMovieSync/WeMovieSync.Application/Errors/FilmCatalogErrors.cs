using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using ErrorOr;

namespace WeMovieSync.Application.Errors
{
    public static class FilmCatalogErrors
    {
        // 404 — не найдено
        public static Error FilmNotFound(long filmId) =>
            Error.NotFound(
                code: "Film.NotFound",
                description: $"Фильм с ID {filmId} не найден");

        public static Error FilmNotFoundByToken(long token) =>
            Error.NotFound(
                code: "Film.NotFoundByToken",
                description: $"Фильм с токеном {token} не найден");

        // 400 — валидация
        public static Error InvalidFilmToken =>
            Error.Validation(
                code: "Film.InvalidToken",
                description: "Некорректный токен фильма");

        public static Error FilmNameRequired =>
            Error.Validation(
                code: "Film.NameRequired",
                description: "Название фильма обязательно");

        public static Error FilmNameTooLong =>
            Error.Validation(
                code: "Film.NameTooLong",
                description: "Название фильма слишком длинное (максимум 200 символов)");

        public static Error InvalidYear =>
            Error.Validation(
                code: "Film.InvalidYear",
                description: "Год выпуска должен быть в диапазоне 1888–2100");

        public static Error InvalidDuration =>
            Error.Validation(
                code: "Film.InvalidDuration",
                description: "Продолжительность фильма должна быть больше 0 минут");

        public static Error InvalidRating =>
            Error.Validation(
                code: "Film.InvalidRating",
                description: "Рейтинг должен быть в диапазоне 0.0–10.0");

        // 409 — конфликт (дубликат)
        public static Error FilmTokenAlreadyExists(string token) =>
            Error.Conflict(
                code: "Film.TokenAlreadyExists",
                description: $"Фильм с токеном {token} уже существует");

        // 403 — доступ запрещён (если будут приватные/возрастные фильмы)
        public static Error FilmAgeRestricted =>
            Error.Forbidden(
                code: "Film.AgeRestricted",
                description: "Фильм имеет возрастное ограничение");

        // 500 — технические (редко, но полезно)
        public static Error FilmSaveFailed =>
            Error.Failure(
                code: "Film.SaveFailed",
                description: "Не удалось сохранить фильм в базу данных");

        public static Error FilmUpdateFailed =>
            Error.Failure(
                code: "Film.UpdateFailed",
                description: "Не удалось обновить информацию о фильме");
    }
}