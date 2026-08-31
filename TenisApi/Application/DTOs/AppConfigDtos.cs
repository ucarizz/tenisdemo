using System.Text.Json.Serialization;

namespace TenisApi.Application.DTOs
{
    public class VersionCheckResponseDto
    {
        [JsonPropertyName("is_update_required")]
        public bool IsUpdateRequired { get; set; }

        [JsonPropertyName("is_update_available")]
        public bool IsUpdateAvailable { get; set; }

        [JsonPropertyName("latest_version")]
        public string LatestVersion { get; set; } = string.Empty;

        [JsonPropertyName("minimum_required_version")]
        public string MinimumRequiredVersion { get; set; } = string.Empty;

        [JsonPropertyName("app_store_url")]
        public string? AppStoreUrl { get; set; }

        [JsonPropertyName("update_message")]
        public string? UpdateMessage { get; set; }
    }
}
