using Microsoft.EntityFrameworkCore;
using SocialCoreService.Models;
using System.Diagnostics;

namespace SocialCoreService.Context
{
    public class SocialCoreContext : DbContext
    {
        public SocialCoreContext(DbContextOptions<SocialCoreContext> options)
    : base(options)
        {
        }

        public DbSet<Users> Users { get; set; } = null!;
        public DbSet<RefreshToken> RefreshTokens { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<RefreshToken>()
                .HasOne(rt => rt.User)
                .WithMany(u => u.RefreshTokens) 
                .HasForeignKey(rt => rt.UserId)
                .OnDelete(DeleteBehavior.Cascade); 

            modelBuilder.Entity<RefreshToken>()
                .HasKey(rt => rt.Id);

            modelBuilder.Entity<Users>()
                .HasKey(u => u.UserId);
        }

    }
}
