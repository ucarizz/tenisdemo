using System;

namespace TenisApi.Application.DTOs
{
    public class CreateSwingRecordRequest
    {
        public double SpeedKmh { get; set; }
        public double AccelerationG { get; set; }
        public string SwingType { get; set; } = "Unknown";
        public DateTime RecordedAt { get; set; } = DateTime.UtcNow;
        public int? MatchId { get; set; }
    }

    public class SwingRecordResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public double SpeedKmh { get; set; }
        public double AccelerationG { get; set; }
        public string SwingType { get; set; } = null!;
        public DateTime RecordedAt { get; set; }
        public int? MatchId { get; set; }
    }
}
