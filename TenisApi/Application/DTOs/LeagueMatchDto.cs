using System.Collections.Generic;

namespace TenisApi.Application.DTOs
{
    public class LeagueMatchDto
    {
        public int Id { get; set; }
        public string Player1Name { get; set; } = string.Empty;
        public string Player2Name { get; set; } = string.Empty;
        public string MatchDate { get; set; } = string.Empty;
        public string? Score { get; set; }
        public bool IsCompleted { get; set; }
        
        [System.Text.Json.Serialization.JsonPropertyName("create_date")]
        public DateTime CreateDate { get; set; }

        [System.Text.Json.Serialization.JsonPropertyName("is_double")]
        public bool IsDouble { get; set; }

        [System.Text.Json.Serialization.JsonPropertyName("player_1_partner_name")]
        public string? Player1PartnerName { get; set; }

        [System.Text.Json.Serialization.JsonPropertyName("player_2_partner_name")]
        public string? Player2PartnerName { get; set; }
        
        // Maçın sayı geçmişini API istemcisine sunmak için liste ekliyoruz
        public List<MatchPointHistoryDto> PointHistories { get; set; } = new();
    }
}
