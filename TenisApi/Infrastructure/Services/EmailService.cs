using System;
using System.Net;
using System.Net.Mail;
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

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public async Task SendEmailAsync(string toEmail, string subject, string body)
        {
            var smtpSettings = _configuration.GetSection("SmtpSettings");
            var host = smtpSettings.GetValue<string>("Host");
            var username = smtpSettings.GetValue<string>("Username");

            if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(username))
            {
                // MOCK/LOG MODE for development
                _logger.LogWarning("************************************************************");
                _logger.LogWarning("SMTP settings are not configured in appsettings.json. Logging email to terminal instead:");
                _logger.LogWarning("TO: {ToEmail}", toEmail);
                _logger.LogWarning("SUBJECT: {Subject}", subject);
                _logger.LogWarning("BODY: {Body}", body);
                _logger.LogWarning("************************************************************");
                return;
            }

            var port = smtpSettings.GetValue<int>("Port", 587);
            var password = smtpSettings.GetValue<string>("Password") ?? string.Empty;
            var enableSsl = smtpSettings.GetValue<bool>("EnableSsl", true);
            var fromAddress = smtpSettings.GetValue<string>("FromAddress") ?? "noreply@tenisligi.com";
            var fromName = smtpSettings.GetValue<string>("FromName") ?? "Tenis Ligi";

            try
            {
                using var mailMessage = new MailMessage
                {
                    From = new MailAddress(fromAddress, fromName),
                    Subject = subject,
                    Body = body,
                    IsBodyHtml = true
                };

                mailMessage.To.Add(toEmail);

                using var smtpClient = new SmtpClient(host, port)
                {
                    Credentials = new NetworkCredential(username, password),
                    EnableSsl = enableSsl
                };

                await smtpClient.SendMailAsync(mailMessage);
                _logger.LogInformation("Email sent successfully to {ToEmail}.", toEmail);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email to {ToEmail} via SMTP.", toEmail);
                throw;
            }
        }
    }
}
