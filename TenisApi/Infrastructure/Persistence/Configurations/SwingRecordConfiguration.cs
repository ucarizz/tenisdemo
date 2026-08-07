using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TenisApi.Domain.Entities;

namespace TenisApi.Infrastructure.Persistence.Configurations
{
    public class SwingRecordConfiguration : IEntityTypeConfiguration<SwingRecord>
    {
        public void Configure(EntityTypeBuilder<SwingRecord> builder)
        {
            builder.ToTable("swing_records");

            builder.HasKey(x => x.Id);
            builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedOnAdd();
            builder.Property(x => x.UserId).HasColumnName("user_id").IsRequired();
            builder.Property(x => x.SpeedKmh).HasColumnName("speed_kmh").IsRequired();
            builder.Property(x => x.AccelerationG).HasColumnName("acceleration_g").IsRequired();
            builder.Property(x => x.SwingType).HasColumnName("swing_type").HasMaxLength(50).IsRequired();
            builder.Property(x => x.RecordedAt).HasColumnName("recorded_at").IsRequired();

            // İlişkiler: Bir kullanıcının birden fazla vuruş kaydı olabilir
            builder.HasOne(x => x.User)
                   .WithMany()
                   .HasForeignKey(x => x.UserId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
