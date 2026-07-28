using System.Text.Json.Serialization;

namespace TenisApi.Application.DTOs
{
    public class MatchPointHistoryDto
    {
        [JsonPropertyName("p1_points")]
        public int P1Points { get; set; }

        [JsonPropertyName("p2_points")]
        public int P2Points { get; set; }
        
        [JsonPropertyName("p1_games")]
        public int P1Games { get; set; }

        [JsonPropertyName("p2_games")]
        public int P2Games { get; set; }
        
        [JsonPropertyName("p1_sets")]
        public int P1Sets { get; set; }

        [JsonPropertyName("p2_sets")]
        public int P2Sets { get; set; }
        
        [JsonPropertyName("server")]
        public string Server { get; set; } = string.Empty;

        [JsonPropertyName("sequence_number")]
        public int SequenceNumber { get; set; }
    }
}
