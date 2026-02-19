using Microsoft.EntityFrameworkCore;
using WeMovieSync.Core.Models;

namespace WeMovieSync.Infrastructure.Context
{
    public class WeMovieSyncContext : DbContext
    {
        public WeMovieSyncContext(DbContextOptions<WeMovieSyncContext> options)
    : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
        public DbSet<Chat> Chats { get; set; }
        public DbSet<ChatMember> ChatMembers { get; set; }
        public DbSet<Message> Messages { get; set; }
        public DbSet<MessageRead> MessagesReads{ get; set; }
        public DbSet<FilmCatalog> FilmCatalog { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<RefreshToken>()
                .HasOne(rt => rt.User)
                .WithMany(u => u.RefreshTokens) 
                .HasForeignKey(rt => rt.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // ChatMember - составной ключ
            modelBuilder.Entity<ChatMember>()
                .HasKey(cm => new { cm.ChatId, cm.UserId });

            // MessageRead - составной ключ
            modelBuilder.Entity<MessageRead>()
                .HasKey(mr => new { mr.MessageId, mr.UserId });

            // Индексы для скорости
            modelBuilder.Entity<Message>()
                .HasIndex(m => new { m.ChatId, m.SentAt })
                .IsDescending();

            modelBuilder.Entity<Message>()
                .HasOne(m => m.Sender)
                .WithMany()
                .HasForeignKey(m => m.SenderId)
                .OnDelete(DeleteBehavior.Restrict);  // не удалять сообщения при удалении юзера

            modelBuilder.Entity<Message>()
                .HasOne(m => m.Chat)
                .WithMany(c => c.Messages)
                .HasForeignKey(m => m.ChatId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<RefreshToken>()
                .HasKey(rt => rt.Id);

            modelBuilder.Entity<User>()
                .HasKey(u => u.Id);

            // Уникальный индекс для Email
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // Уникальный индекс для Nickname
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Nickname)
                .IsUnique();

            modelBuilder.Entity<FilmCatalog>()
                .HasIndex(f => f.Token)
                .IsUnique();
        }

    }
}
