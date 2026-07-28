using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TenisApi.Domain.Entities;

namespace TenisApi.Infrastructure.Persistence.Configurations
{
    public class MatchPointHistoryConfiguration : IEntityTypeConfiguration<MatchPointHistory>
    {
        public void Configure(EntityTypeBuilder<MatchPointHistory> builder)
        {
            builder.ToTable("match_point_histories");

            builder.HasKey(h => h.Id);

            builder.Property(h => h.Id)
                .ValueGeneratedOnAdd();

            builder.Property(h => h.P1Points)
                .IsRequired();

            builder.Property(h => h.P2Points)
                .IsRequired();

            builder.Property(h => h.P1Games)
                .IsRequired();

            builder.Property(h => h.P2Games)
                .IsRequired();

            builder.Property(h => h.P1Sets)
                .IsRequired();

            builder.Property(h => h.P2Sets)
                .IsRequired();

            builder.Property(h => h.Server)
                .HasMaxLength(20)
                .IsRequired();

            builder.Property(h => h.SequenceNumber)
                .IsRequired();
        }
    }
}
