using System.Text.Json.Serialization;

namespace TenisApi.Application.DTOs
{
    public class MatchPointHistoryDto
    {
        [JsonPropertyName("p1_points")]
        public string P1Points { get; set; } = string.Empty;

        [JsonPropertyName("p2_points")]
        public string P2Points { get; set; } = string.Empty;
        
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

        [JsonPropertyName("created_time")]
        public System.DateTime CreatedTime { get; set; } = System.DateTime.UtcNow;
    }
}
