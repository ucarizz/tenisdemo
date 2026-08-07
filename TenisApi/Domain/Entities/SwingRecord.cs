using System;

namespace TenisApi.Domain.Entities
{
    public class SwingRecord
    {
        public int Id { get; private set; }
        public int UserId { get; private set; }
        public double SpeedKmh { get; private set; }
        public double AccelerationG { get; private set; }
        public string SwingType { get; private set; }
        public DateTime RecordedAt { get; private set; }

        // Navigation property for EF Core
        public User User { get; private set; } = null!;

        #pragma warning disable CS8618 // EF Core için gerekli boş kurucu metot
        private SwingRecord() { }
        #pragma warning restore CS8618

        public SwingRecord(int userId, double speedKmh, double accelerationG, string swingType, DateTime recordedAt)
        {
            if (speedKmh <= 0)
                throw new ArgumentException("Hız sıfırdan büyük olmalıdır.", nameof(speedKmh));
            if (string.IsNullOrWhiteSpace(swingType))
                throw new ArgumentException("Vuruş türü boş olamaz.", nameof(swingType));

            UserId = userId;
            SpeedKmh = speedKmh;
            AccelerationG = accelerationG;
            SwingType = swingType.Trim();
            RecordedAt = recordedAt;
        }
    }
}
