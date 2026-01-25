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

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<RefreshToken>()
                .HasOne(rt => rt.User)
                .WithMany(u => u.RefreshTokens) 
                .HasForeignKey(rt => rt.UserId)
                .OnDelete(DeleteBehavior.Cascade); 

            modelBuilder.Entity<RefreshToken>()
                .HasKey(rt => rt.Id);

            modelBuilder.Entity<User>()
                .HasKey(u => u.Id);
        }

    }
}
