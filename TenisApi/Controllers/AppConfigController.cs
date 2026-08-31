using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using TenisApi.Application.DTOs;

namespace TenisApi.Controllers
{
    [ApiController]
    [Route("v1/app-config")]
    public class AppConfigController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public AppConfigController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet("version-check")]
        public ActionResult<VersionCheckResponseDto> CheckVersion([FromQuery] string platform, [FromQuery] string version)
        {
            if (string.IsNullOrEmpty(platform) || string.IsNullOrEmpty(version))
            {
                return BadRequest(new { message = "Platform ve versiyon parametreleri zorunludur." });
            }

            // appsettings.json'dan konfigürasyonu oku
            var configSection = _configuration.GetSection("AppConfig");
            var minRequired = configSection.GetValue<string>("MinimumRequiredVersion") ?? "1.0.0";
            var latest = configSection.GetValue<string>("LatestVersion") ?? "1.0.0";
            var appStoreUrl = configSection.GetValue<string>("AppStoreUrl") ?? "https://apps.apple.com";
            var updateMessage = configSection.GetValue<string>("UpdateMessage") ?? "Yeni bir güncelleme mevcut. Lütfen uygulamanızı güncelleyin.";

            // Versiyon karşılaştırma mantığı
            bool isUpdateRequired = CompareVersions(version, minRequired) < 0;
            bool isUpdateAvailable = CompareVersions(version, latest) < 0;

            var response = new VersionCheckResponseDto
            {
                IsUpdateRequired = isUpdateRequired,
                IsUpdateAvailable = isUpdateAvailable,
                LatestVersion = latest,
                MinimumRequiredVersion = minRequired,
                AppStoreUrl = appStoreUrl,
                UpdateMessage = updateMessage
            };

            return Ok(response);
        }

        /// <summary>
        /// Semantik versiyonları karşılaştırır.
        /// </summary>
        /// <returns>
        /// versionA < versionB ise -1,
        /// versionA > versionB ise 1,
        /// Eşitse 0 döner.
        /// </returns>
        private static int CompareVersions(string versionA, string versionB)
        {
            var partsA = versionA.Split('.');
            var partsB = versionB.Split('.');
            int maxLength = Math.Max(partsA.Length, partsB.Length);

            for (int i = 0; i < maxLength; i++)
            {
                int valA = i < partsA.Length && int.TryParse(partsA[i], out var parsedA) ? parsedA : 0;
                int valB = i < partsB.Length && int.TryParse(partsB[i], out var parsedB) ? parsedB : 0;

                if (valA != valB)
                {
                    return valA.CompareTo(valB);
                }
            }

            return 0;
        }
    }
}
