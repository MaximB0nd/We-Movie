using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using WeMovieSync.Application.Interfaces;
using WeMovieSync.Application.Services; 
using WeMovieSync.Infrastructure.Context;
using WeMovieSync.Infrastructure.Repositories;

var builder = WebApplication.CreateBuilder(args);

// 1. Контроллеры
builder.Services.AddControllers();

// 2. Swagger + JWT-кнопка Authorize
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "WeMovieSync API", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: 'Bearer {token}'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

// 3. JWT-аутентификация
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

// 4. Авторизация
builder.Services.AddAuthorization();

// 5. CORS (для Swift и тестов)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// 6. DbContext
builder.Services.AddDbContext<WeMovieSyncContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// 7. Регистрация сервисов и репозиториев
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserRepository, UserRepository>();



var app = builder.Build();

// Middleware
//if (app.Environment.IsDevelopment() || app.Environment.EnvironmentName == "Docker")
//{
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "WeMovieSync API v1"));
    app.UseDeveloperExceptionPage(); // детальные ошибки
//}

app.UseCors("AllowAll");

app.UseHttpsRedirection();

app.UseAuthentication();   // обязательно перед UseAuthorization
app.UseAuthorization();

app.MapControllers();


// Migration
if (app.Environment.IsProduction() )
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<WeMovieSyncContext>();
    db.Database.Migrate();  // применяет миграции автоматически при запуске
}

app.Run();