# Этап 1: сборка
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Копируем .csproj
COPY WeMovieSync.API/WeMovieSync.API.csproj WeMovieSync.API/
COPY WeMovieSync.Application/WeMovieSync.Application.csproj WeMovieSync.Application/
COPY WeMovieSync.Core/WeMovieSync.Core.csproj WeMovieSync.Core/
COPY WeMovieSync.Infrastructure/WeMovieSync.Infrastructure.csproj WeMovieSync.Infrastructure/

# Восстанавливаем зависимости
RUN dotnet restore WeMovieSync.API/WeMovieSync.API.csproj

# Копируем весь код
COPY . .

# Публикуем
WORKDIR /src/WeMovieSync.API
RUN dotnet publish WeMovieSync.API.csproj -c Release -o /app/publish /p:UseAppHost=false

# Этап 2: runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "WeMovieSync.API.dll"]