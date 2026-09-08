using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using TenisApi.Application.Services;

namespace TenisApi.Infrastructure.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;
        private readonly HttpClient _httpClient;

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger, HttpClient httpClient)
        {
            _configuration = configuration;
            _logger = logger;
            _httpClient = httpClient;
        }

        public async Task SendEmailAsync(string toEmail, string subject, string body)
        {
            var smtpSettings = _configuration.GetSection("SmtpSettings");
            var apiKey = smtpSettings.GetValue<string>("Password");

            if (string.IsNullOrWhiteSpace(apiKey) || apiKey == "YOUR_RESEND_API_KEY_HERE" || apiKey.Contains("YOUR_RESEND"))
            {
                // MOCK/LOG MODE for development
                _logger.LogWarning("************************************************************");
                _logger.LogWarning("Resend API Key is not configured. Logging email to terminal instead:");
                _logger.LogWarning("TO: {ToEmail}", toEmail);
                _logger.LogWarning("SUBJECT: {Subject}", subject);
                _logger.LogWarning("BODY: {Body}", body);
                _logger.LogWarning("************************************************************");
                return;
            }

            var fromAddress = smtpSettings.GetValue<string>("FromAddress") ?? "noreply@courtmate.com.tr";
            var fromName = smtpSettings.GetValue<string>("FromName") ?? "CourtMate";

            try
            {
                // Resend API Mail formatı
                var payload = new
                {
                    from = $"{fromName} <{fromAddress}>",
                    to = new[] { toEmail },
                    subject = subject,
                    html = body
                };

                var jsonPayload = JsonSerializer.Serialize(payload);
                
                using var request = new HttpRequestMessage(HttpMethod.Post, "https://api.resend.com/emails");
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
                request.Content = new StringContent(jsonPayload, Encoding.UTF8, "application/json");

                _logger.LogInformation("Sending email to {ToEmail} via Resend HTTP API...", toEmail);
                
                var response = await _httpClient.SendAsync(request);
                
                if (!response.IsSuccessStatusCode)
                {
                    var errorResponse = await response.Content.ReadAsStringAsync();
                    _logger.LogError("Resend API returned error code {StatusCode}: {ErrorResponse}", response.StatusCode, errorResponse);
                    throw new Exception($"Resend API error: {response.StatusCode} - {errorResponse}");
                }

                _logger.LogInformation("Email sent successfully to {ToEmail} via Resend HTTP API.", toEmail);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email to {ToEmail} via Resend HTTP API.", toEmail);
                throw;
            }
        }
    }
}
