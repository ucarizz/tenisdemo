using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace TenisApi.Application.DTOs
{
    public class LobbySettingsDto
    {
        [JsonPropertyName("games_per_set")]
        public int GamesPerSet { get; set; } = 4;

        [JsonPropertyName("sets_to_win")]
        public int SetsToWin { get; set; } = 2;

        [JsonPropertyName("use_match_tiebreak")]
        public bool UseMatchTiebreak { get; set; } = true;
    }

    public class LobbyPlayerDto
    {
        [JsonPropertyName("connection_id")]
        public string ConnectionId { get; set; } = string.Empty;

        [JsonPropertyName("user_id")]
        public string? UserId { get; set; }

        [JsonPropertyName("name")]
        public string Name { get; set; } = string.Empty;

        [JsonPropertyName("profile_image_url")]
        public string? ProfileImageUrl { get; set; }

        [JsonPropertyName("team")]
        public int Team { get; set; } = 1;

        [JsonPropertyName("slot_index")]
        public int SlotIndex { get; set; } = 0;

        [JsonPropertyName("is_host")]
        public bool IsHost { get; set; }

        [JsonPropertyName("is_ready")]
        public bool IsReady { get; set; } = true;
    }

    public class LobbyStateDto
    {
        [JsonPropertyName("code")]
        public string Code { get; set; } = string.Empty;

        [JsonPropertyName("host_name")]
        public string HostName { get; set; } = string.Empty;

        [JsonPropertyName("host_profile_image_url")]
        public string? HostProfileImageUrl { get; set; }

        [JsonPropertyName("guest_profile_image_url")]
        public string? GuestProfileImageUrl { get; set; }

        [JsonPropertyName("host_partner_name")]
        public string? HostPartnerName { get; set; }

        [JsonPropertyName("guest_name")]
        public string? GuestName { get; set; }

        [JsonPropertyName("guest_partner_name")]
        public string? GuestPartnerName { get; set; }

        [JsonPropertyName("is_double")]
        public bool IsDouble { get; set; }

        [JsonPropertyName("settings")]
        public LobbySettingsDto Settings { get; set; } = new();

        [JsonPropertyName("is_match_started")]
        public bool IsMatchStarted { get; set; }

        [JsonPropertyName("match_id")]
        public int? MatchId { get; set; }

        [JsonPropertyName("players")]
        public List<LobbyPlayerDto> Players { get; set; } = new();

        [JsonPropertyName("max_players")]
        public int MaxPlayers => IsDouble ? 4 : 2;
    }

    public class SetScoreDto
    {
        [JsonPropertyName("p1_games")]
        public int P1Games { get; set; }

        [JsonPropertyName("p2_games")]
        public int P2Games { get; set; }
    }

    public class LiveMatchStateDto
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

        [JsonPropertyName("set_scores")]
        public List<SetScoreDto> SetScores { get; set; } = new();

        [JsonPropertyName("is_tiebreak")]
        public bool IsTiebreak { get; set; }

        [JsonPropertyName("is_match_tiebreak")]
        public bool IsMatchTiebreak { get; set; }

        [JsonPropertyName("server")]
        public string Server { get; set; } = "SİZ";

        [JsonPropertyName("is_match_over")]
        public bool IsMatchOver { get; set; }

        [JsonPropertyName("history")]
        public List<MatchPointHistoryDto> History { get; set; } = new();

        [JsonPropertyName("winner")]
        public string? Winner { get; set; }

        [JsonPropertyName("is_game_break")]
        public bool IsGameBreak { get; set; } = false;
    }
}
