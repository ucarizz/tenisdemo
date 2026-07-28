using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TenisApi.Domain.Entities;

namespace TenisApi.Infrastructure.Persistence.Configurations
{
    public class LeagueMatchConfiguration : IEntityTypeConfiguration<LeagueMatch>
    {
        public void Configure(EntityTypeBuilder<LeagueMatch> builder)
        {
            builder.ToTable("matches");

            builder.HasKey(m => m.Id);

            builder.Property(m => m.Id)
                .ValueGeneratedOnAdd();

            builder.Property(m => m.Player1Name)
                .HasMaxLength(100)
                .IsRequired();

            builder.Property(m => m.Player2Name)
                .HasMaxLength(100)
                .IsRequired();

            builder.Property(m => m.MatchDate)
                .HasMaxLength(50)
                .IsRequired();

            builder.Property(m => m.Score)
                .HasMaxLength(50)
                .IsRequired(false);

            builder.Property(m => m.IsCompleted)
                .IsRequired();

            builder.Property(m => m.CreateDate)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .IsRequired();

            builder.Property(m => m.IsDouble)
                .HasDefaultValue(false)
                .IsRequired();

            builder.Property(m => m.Player1PartnerName)
                .HasMaxLength(100)
                .IsRequired(false);

            builder.Property(m => m.Player2PartnerName)
                .HasMaxLength(100)
                .IsRequired(false);

            builder.Property(m => m.HostUserId)
                .IsRequired(false);

            builder.Property(m => m.GuestUserId)
                .IsRequired(false);

            builder.HasOne<User>()
                .WithMany()
                .HasForeignKey(m => m.HostUserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne<User>()
                .WithMany()
                .HasForeignKey(m => m.GuestUserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Bire çok ilişkide MatchPointHistory tablosunu bağlıyoruz (Cascade Delete ile)
            builder.HasMany(m => m.PointHistories)
                .WithOne()
                .HasForeignKey(h => h.MatchId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
