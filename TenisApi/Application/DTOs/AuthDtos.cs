using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace TenisApi.Application.DTOs
{
    public class RegisterRequest
    {
        [Required]
        [EmailAddress]
        [JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        [JsonPropertyName("password")]
        public string Password { get; set; } = string.Empty;

        [Required]
        [JsonPropertyName("full_name")]
        public string FullName { get; set; } = string.Empty;
    }

    public class LoginRequest
    {
        [Required]
        [EmailAddress]
        [JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;

        [Required]
        [JsonPropertyName("password")]
        public string Password { get; set; } = string.Empty;
    }

    public class AuthResponse
    {
        [JsonPropertyName("token")]
        public string Token { get; set; } = string.Empty;

        [JsonPropertyName("user")]
        public UserDto User { get; set; } = new();
    }

    public class SendOtpRequest
    {
        [Required]
        [EmailAddress]
        [JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;
    }

    public class VerifyOtpRequest
    {
        [Required]
        [EmailAddress]
        [JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;

        [Required]
        [StringLength(6, MinimumLength = 6)]
        [JsonPropertyName("code")]
        public string Code { get; set; } = string.Empty;

        [JsonPropertyName("full_name")]
        public string? FullName { get; set; }
    }

    public class VerifyOtpResponse
    {
        [JsonPropertyName("requires_full_name")]
        public bool RequiresFullName { get; set; }

        [JsonPropertyName("token")]
        public string? Token { get; set; }

        [JsonPropertyName("user")]
        public UserDto? User { get; set; }
    }
}
