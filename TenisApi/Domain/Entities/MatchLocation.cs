using System;

namespace TenisApi.Domain.Entities
{
    public class MatchLocation
    {
        public int Id { get; private set; }
        public int MatchId { get; private set; }
        public double Latitude { get; private set; }
        public double Longitude { get; private set; }
        public DateTime Timestamp { get; private set; }

        // Navigation property for EF Core
        public LeagueMatch Match { get; private set; } = null!;

        #pragma warning disable CS8618 // EF Core constructor requirement
        private MatchLocation() { }
        #pragma warning restore CS8618

        public MatchLocation(int matchId, double latitude, double longitude, DateTime timestamp)
        {
            MatchId = matchId;
            Latitude = latitude;
            Longitude = longitude;
            Timestamp = timestamp;
        }
    }
}
