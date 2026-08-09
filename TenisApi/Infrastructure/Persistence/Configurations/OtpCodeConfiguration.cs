using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TenisApi.Domain.Entities;

namespace TenisApi.Infrastructure.Persistence.Configurations
{
    public class OtpCodeConfiguration : IEntityTypeConfiguration<OtpCode>
    {
        public void Configure(EntityTypeBuilder<OtpCode> builder)
        {
            builder.ToTable("otp_codes");

            builder.HasKey(o => o.Id);

            builder.Property(o => o.Id)
                .ValueGeneratedOnAdd();

            builder.Property(o => o.Email)
                .HasMaxLength(150)
                .IsRequired();

            builder.Property(o => o.Code)
                .HasMaxLength(6)
                .IsRequired();

            builder.Property(o => o.CreatedAt)
                .IsRequired();

            builder.Property(o => o.ExpiresAt)
                .IsRequired();

            builder.Property(o => o.IsUsed)
                .IsRequired()
                .HasDefaultValue(false);
        }
    }
}
