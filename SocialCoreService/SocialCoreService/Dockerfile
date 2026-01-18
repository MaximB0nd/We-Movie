# Stage 1: Сборка
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["SocialCoreService.csproj", "./"]
RUN dotnet restore "SocialCoreService.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet publish "SocialCoreService.csproj" -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "SocialCoreService.dll"]