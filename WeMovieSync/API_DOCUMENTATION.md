# We&Movie — API документация для фронтендера

> Backend для мобильного приложения совместного просмотра фильмов в реальном времени.

---

## Содержание

1. [Общая информация](#общая-информация)
2. [Аутентификация](#аутентификация)
3. [REST API](#rest-api)
4. [WebSocket (SignalR)](#websocket-signalr)
5. [DTO — структуры данных](#dto--структуры-данных)
6. [Обработка ошибок](#обработка-ошибок)
7. [Статистика проекта](#статистика-проекта)

---

## Общая информация

### Базовый URL
```
https://<your-server>/api
```

### Swagger
- Доступен по адресу: `/swagger`
- Поддержка JWT: кнопка **Authorize** — ввести `Bearer <access_token>`

### Особенности
- **Авторизация**: JWT Bearer Token для всех эндпоинтов, кроме Auth
- **CORS**: политика `AllowAll` (все origins, методы, заголовки)
- **Формат ответов**: JSON
- **Ошибки**: строка с описанием или объект (см. [Обработка ошибок](#обработка-ошибок))

---

## Аутентификация

### Формат заголовка для защищённых эндпоинтов
```
Authorization: Bearer <access_token>
```

### Эндпоинты без авторизации
| Метод | Путь | Описание |
|-------|------|----------|
| POST | `/api/Auth/register` | Регистрация |
| POST | `/api/Auth/login` | Вход |
| POST | `/api/Auth/refresh` | Обновление токена |

### Все остальные эндпоинты требуют `[Authorize]`

---

## REST API

### 1. Auth — `/api/Auth`

#### POST `/api/Auth/register`
Регистрация нового пользователя.

**Request Body:**
```json
{
  "name": "Иван Иванов",
  "nickname": "ivan_film",
  "email": "ivan@example.com",
  "password": "secret123"
}
```

| Поле | Тип | Обязательно | Валидация |
|------|-----|-------------|-----------|
| name | string | ✅ | min 2 символа |
| nickname | string | ✅ | max 50 |
| email | string | ✅ | email |
| password | string | ✅ | min 6 символов |

**Success (200):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "unique-refresh-token-string",
  "expiresIn": 3600,
  "user": {
    "nickname": "ivan_film",
    "email": "ivan@example.com"
  }
}
```

---

#### POST `/api/Auth/login`
Вход по email **или** nickname + пароль.

**Request Body:**
```json
{
  "email": "ivan@example.com",
  "nickname": null,
  "password": "secret123"
}
```
или
```json
{
  "email": null,
  "nickname": "ivan_film",
  "password": "secret123"
}
```

| Поле | Тип | Обязательно | Примечание |
|------|-----|-------------|------------|
| email | string | — | Для входа по email |
| nickname | string | — | Для входа по nickname |
| password | string | ✅ | min 6 символов |

**Success (200):** тот же формат, что и `register`.

---

#### POST `/api/Auth/refresh`
Обновление access token по refresh token.

**Request Body:**
```json
{
  "refreshToken": "your-refresh-token"
}
```

**Success (200):** тот же формат, что и `register`.

---

### 2. Chat (комнаты) — `/api/Chat`

Все эндпоинты требуют `Authorization: Bearer <token>`.

#### GET `/api/Chat/chats`
Список всех чатов/комнат пользователя.

**Success (200):**
```json
[
  {
    "id": 1,
    "name": "Киновечер с друзьями",
    "lastMessagePreview": "Давай смотреть!",
    "lastMessageTime": "2025-03-01T20:00:00Z",
    "unreadCount": 0,
    "members": [
      { "id": 1, "nickname": "ivan_film" },
      { "id": 2, "nickname": "mary_cinema" }
    ]
  }
]
```

---

#### POST `/api/Chat/room`
Создание комнаты просмотра.

**Request Body:**
```json
{
  "name": "Субботний киновечер",
  "token": 0
}
```

| Поле | Тип | Примечание |
|------|-----|------------|
| name | string | Название комнаты |
| token | long | (в DTO есть, в логике может не использоваться) |

**Success (200):** `long` — ID созданной комнаты.

---

#### DELETE `/api/Chat/{chatId}`
Удаление чата/комнаты. Только **host** или **moderator**.

**Success (200):** пустое тело.

---

#### PUT `/api/Chat/{chatId}/add-member`
Добавить участника в комнату. Только host/modifier.

**Request Body:**
```json
{
  "userId": 5
}
```

---

#### PUT `/api/Chat/{chatId}/remove-member`
Удалить участника из комнаты. Только host/modifier.

**Request Body:**
```json
{
  "userId": 5
}
```

---

#### PUT `/api/Chat/rooms/{roomId}/connect-film`
Привязать фильм к комнате. Только host/modifier.

**Request Body:**
```json
{
  "token": 42
}
```

**Success (200):**
```json
{
  "filmName": "Интерстеллар",
  "mediaLink": "https://..."
}
```

---

#### GET `/api/Chat/rooms/{roomId}/player-state`
Текущее состояние плеера в комнате. Доступно всем участникам.

**Success (200):**
```json
{
  "roomId": 1,
  "currentFilmId": 42,
  "filmName": "Интерстеллар",
  "mediaLink": "https://...",
  "currentPositionSeconds": 120.5,
  "isPaused": false,
  "playbackRate": 1.0,
  "hostUserId": 1,
  "updatedByUserId": 1,
  "updatedAt": "2025-03-01T20:00:00Z"
}
```

---

#### PUT `/api/Chat/rooms/{roomId}/player-state`
Обновить состояние плеера. Только host/modifier.

**Request Body:**
```json
{
  "action": "seek",
  "positionSeconds": 90.0,
  "playbackRate": null,
  "newFilmToken": null,
  "isPaused": null
}
```

| Поле | Тип | Описание |
|------|-----|----------|
| action | string | `"play"`, `"pause"`, `"seek"`, `"rate"`, `"changeFilm"` |
| positionSeconds | double? | Позиция (сек) — для `seek` |
| playbackRate | float? | Скорость — для `rate` |
| newFilmToken | long? | Токен фильма — для `changeFilm` |
| isPaused | bool? | Совместимость |

---

#### PUT `/api/Chat/rooms/{roomId}/grant-moderator`
Назначить модератора. Только **host**.

**Request Body:**
```json
{
  "userId": 3
}
```

---

#### PUT `/api/Chat/rooms/{roomId}/revoke-moderator`
Снять модератора. Только **host**.

**Request Body:**
```json
{
  "userId": 3
}
```

---

### 3. Message — `/api/Message`

#### GET `/api/Message/chats/{chatId}/messages`
Сообщения чата (постранично по `lastMessageId`).

**Query:**
| Параметр | Тип | Описание |
|----------|-----|----------|
| lastMessageId | long? | ID последнего сообщения (для пагинации) |

**Success (200):**
```json
[
  {
    "messageId": 1,
    "senderId": 2,
    "senderNickname": "mary_cinema",
    "chatId": 1,
    "text": "Привет!",
    "sentAt": "2025-03-01T20:00:00Z",
    "deliveredAt": null,
    "isReadByCurrentUser": false
  }
]
```

---

#### PUT `/api/Message/messages/{messageId}/read`
Отметить сообщение как прочитанное.

---

#### PUT `/api/Message/chats/{chatId}/read-all`
Отметить все сообщения чата как прочитанные.

---

#### DELETE `/api/Message/messages/{messageId}`
Удалить сообщение.

**Query:**
| Параметр | Тип | Описание |
|----------|-----|----------|
| forAll | bool | `false` — только у себя, `true` — для всех (только админ) |

---

### 4. FilmCatalog — `/api/FilmCatalog`

#### GET `/api/FilmCatalog/films`
Список всех фильмов.

**Success (200):**
```json
{
  "films": [
    {
      "token": 1,
      "totalCount": 100,
      "name": "Интерстеллар",
      "image": [ 137, 80, 78, 71, ... ]
    }
  ],
  "totalCount": 100
}
```
> `image` — массив байтов (base64 при сериализации в некоторых клиентах). На фронте обычно конвертируют в Data URL или отправляют на CDN.

---

#### GET `/api/FilmCatalog/getfilm={filmToken}`
Детальная информация о фильме.

**URL:** `/api/FilmCatalog/getfilm=42` (токен — часть пути)

**Success (200):**
```json
{
  "token": 42,
  "filmName": "Интерстеллар",
  "filmDescription": "Фантастический фильм...",
  "image": [ 137, 80, 78, 71, ... ],
  "category": "Фантастика",
  "duration": "02:49:00"
}
```
> `duration` — `TimeSpan`, сериализуется как строка `"HH:mm:ss"`.

---

## WebSocket (SignalR)

### Подключение
- **URL:** `https://<your-server>/watchHub`
- **Протокол:** SignalR (WebSocket)
- **Авторизация:** Hub помечен `[Authorize]` — требуется JWT.

> Для WebSocket-клиентов, не поддерживающих заголовки, может потребоваться передача `access_token` в query string при подключении. По умолчанию используется стандартный механизм JWT (Bearer в header).

### Методы, вызываемые клиентом

| Метод | Параметры | Описание |
|-------|-----------|----------|
| `JoinRoom` | `roomId: long` | Подключиться к комнате. Проверяется членство. Клиент получает текущее состояние плеера и уведомление о входе. |
| `LeaveRoom` | `roomId: long` | Выйти из комнаты. Остальным уходит событие `MemberLeft`. |
| `SendPlayerAction` | `roomId: long`, `action: PlayerActionDTO` | Обновить состояние плеера (play, pause, seek и т.д.). Только host/modifier. |
| `SendChatMessage` | `dto: SendMessageRequestDTO` | Отправить сообщение в чат комнаты. |

### События, принимаемые клиентом

| Событие | Payload | Описание |
|---------|---------|----------|
| `PlayerStateUpdated` | `PlayerStateDTO` | Обновлённое состояние плеера (после JoinRoom или SendPlayerAction). |
| `MemberJoined` | `RoomEventDTO` | Пользователь вошёл в комнату. |
| `MemberLeft` | `RoomEventDTO` | Пользователь вышел из комнаты. |
| `ReceiveMessage` | объект | Новое сообщение в чате. |
| `Error` | `string` | Текстовое описание ошибки. |

### Формат событий

**RoomEventDTO:**
```json
{
  "eventType": "joined",
  "userId": 2,
  "nickname": "mary_cinema",
  "newRole": null
}
```
`eventType`: `"joined"`, `"left"`, `"role_changed"`.

**ReceiveMessage:**
```json
{
  "messageId": 1,
  "userId": 2,
  "nickname": "mary_cinema",
  "text": "Привет!",
  "sentAt": "2025-03-01T20:00:00Z",
  "isReadByCurrentUser": false
}
```

**SendMessageRequestDTO** (для `SendChatMessage`):
```json
{
  "roomId": 1,
  "text": "Сообщение в чат"
}
```

---

## DTO — структуры данных

| DTO | Использование |
|-----|---------------|
| `RegisterDTO` | POST register |
| `LoginDTO` | POST login |
| `RefreshRequestDto` | POST refresh |
| `AuthResponse` | Ответ Auth (accessToken, refreshToken, expiresIn, user) |
| `UserInfo` | Часть AuthResponse |
| `CreateRoomRequestDTO` | POST room |
| `AddMemberRequestDTO` | PUT add-member |
| `RemoveMemberRequestDTO` | PUT remove-member |
| `ConnectFilmRequestDTO` | PUT connect-film |
| `PlayerActionDTO` | PUT player-state, SendPlayerAction |
| `PlayerStateDTO` | GET player-state, PlayerStateUpdated |
| `RoomEventDTO` | MemberJoined, MemberLeft |
| `ModeratorActionDTO` | grant/revoke moderator |
| `ChatPreviewDto` | GET chats |
| `UserPreviewDto` | В ChatPreviewDto |
| `FilmAndRoomConnectionResponceDTO` | PUT connect-film |
| `SendMessageRequestDTO` | SendChatMessage |
| `GetMessagesResponseDTO` | GET messages, ReceiveMessage (аналогичная структура) |
| `FilmsResponce` | GET films |
| `AllFilmsResponce` | Элемент FilmsResponce.films |
| `FullFilmInfoResponce` | GET getfilm={token} |

---

## Обработка ошибок

Используется библиотека **ErrorOr**. Ошибки возвращаются как **строка** (описание) в теле ответа.

| HTTP | ErrorOr.Type | Пример |
|------|--------------|--------|
| 400 | Validation | Некорректные данные |
| 401 | Unauthorized | Неверный логин/пароль, просроченный токен |
| 403 | Forbidden | Нет прав (модератор, удаление и т.д.) |
| 404 | NotFound | Чат/сообщение/фильм не найден |
| 409 | Conflict | Email/Nick уже занят, сообщение уже удалено |
| 500 | Failure/другое | Внутренняя ошибка |

### Примеры текстов ошибок

- `"Email уже занят"`
- `"Nick уже занят"`
- `"Неверный email/nick или пароль"`
- `"Недействительный refresh token"`
- `"Чат не найден"`
- `"Пользователь не состоит в чате"`
- `"Только хозяин или модератор может удалить комнату"`
- `"Сообщение не найдено"`
- `"Удалять можно только свои сообщения"`
- `"Фильм с токеном X не найден"`

---

## Статистика проекта

| Показатель | Значение |
|------------|----------|
| **Файлов .cs** | 68 |
| **Строк кода** | ~4 450 |

### Структура решения

```
WeMovieSync/
├── WeMovieSync.API/           # Контроллеры, Hub, Program
├── WeMovieSync.Application/   # DTO, сервисы, ошибки
├── WeMovieSync.Core/          # Доменные модели
└── WeMovieSync.Infrastructure/ # БД, репозитории, миграции
```

---

*Документация актуальна на основе анализа кода (март 2025).*
