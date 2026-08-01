using Microsoft.AspNetCore.Mvc;

namespace TenisApi.Controllers
{
    public class ClientLogDto
    {
        public string Level { get; set; } = "Info"; // Info, Warn, Error
        public string Message { get; set; } = string.Empty;
        public string? Source { get; set; } // "iOS" or "watchOS"
        public string? DeviceModel { get; set; }
        public string? OsVersion { get; set; }
    }

    [ApiController]
    [Route("v1/logs")]
    public class LogsController : ControllerBase
    {
        private readonly ILogger<LogsController> _logger;

        public LogsController(ILogger<LogsController> logger)
        {
            _logger = logger;
        }

        [HttpPost("client-diagnostics")]
        public IActionResult LogClientDiagnostics([FromBody] ClientLogDto dto)
        {
            var level = dto.Level?.ToLowerInvariant() ?? "info";
            
            // Structured logging will extract these parameters as searchable fields in Graylog!
            if (level == "error" || level == "fail")
            {
                _logger.LogError("Client Log [{Source} - {DeviceModel} (OS {OsVersion})]: {ClientMessage}", 
                    dto.Source ?? "Unknown", 
                    dto.DeviceModel ?? "Unknown", 
                    dto.OsVersion ?? "Unknown", 
                    dto.Message);
            }
            else if (level == "warn" || level == "warning")
            {
                _logger.LogWarning("Client Log [{Source} - {DeviceModel} (OS {OsVersion})]: {ClientMessage}", 
                    dto.Source ?? "Unknown", 
                    dto.DeviceModel ?? "Unknown", 
                    dto.OsVersion ?? "Unknown", 
                    dto.Message);
            }
            else
            {
                _logger.LogInformation("Client Log [{Source} - {DeviceModel} (OS {OsVersion})]: {ClientMessage}", 
                    dto.Source ?? "Unknown", 
                    dto.DeviceModel ?? "Unknown", 
                    dto.OsVersion ?? "Unknown", 
                    dto.Message);
            }

            return Ok(new { message = "Log received" });
        }
    }
}
