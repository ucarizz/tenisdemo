using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TenisApi.Domain.Entities;

namespace TenisApi.Infrastructure.Persistence.Configurations
{
    public class MatchLocationConfiguration : IEntityTypeConfiguration<MatchLocation>
    {
        public void Configure(EntityTypeBuilder<MatchLocation> builder)
        {
            builder.ToTable("match_locations");

            builder.HasKey(l => l.Id);

            builder.Property(l => l.Id)
                .ValueGeneratedOnAdd();

            builder.Property(l => l.Latitude)
                .IsRequired();

            builder.Property(l => l.Longitude)
                .IsRequired();

            builder.Property(l => l.Timestamp)
                .IsRequired();

            builder.HasOne(l => l.Match)
                .WithMany()
                .HasForeignKey(l => l.MatchId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
