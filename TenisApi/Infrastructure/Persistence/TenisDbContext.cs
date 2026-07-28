using Microsoft.EntityFrameworkCore;
using TenisApi.Domain.Entities;

namespace TenisApi.Infrastructure.Persistence
{
    public class TenisDbContext : DbContext
    {
        public DbSet<LeagueMatch> Matches => Set<LeagueMatch>();
        public DbSet<User> Users => Set<User>();

        public TenisDbContext(DbContextOptions<TenisDbContext> options) : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Mevcut derlemedeki tüm IEntityTypeConfiguration sınıflarını otomatik uygular
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(TenisDbContext).Assembly);
        }
    }
}
