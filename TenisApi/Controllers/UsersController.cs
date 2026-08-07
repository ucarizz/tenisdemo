using System;
using System.IO;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TenisApi.Application.DTOs;
using TenisApi.Infrastructure.Persistence;

namespace TenisApi.Controllers
{
    [ApiController]
    [Route("v1/users")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly TenisDbContext _context;
        private readonly IWebHostEnvironment _environment;

        public UsersController(TenisDbContext context, IWebHostEnvironment environment)
        {
            _context = context;
            _environment = environment;
        }

        [HttpPost("profile-image")]
        [Consumes("multipart/form-data")]
        public async Task<ActionResult<UserDto>> UploadProfileImage([FromForm] IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest(new { message = "Lütfen geçerli bir görsel dosyası seçin." });
            }

            // Dosya boyutu sınırı (5 MB)
            const long maxFileSize = 5 * 1024 * 1024;
            if (file.Length > maxFileSize)
            {
                return BadRequest(new { message = "Görsel boyutu maksimum 5 MB olabilir." });
            }

            // Dosya uzantısı kontrolü
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (Array.IndexOf(allowedExtensions, extension) < 0)
            {
                return BadRequest(new { message = "Sadece JPG, JPEG ve PNG dosyaları kabul edilir." });
            }

            // Kullanıcı kimliğini JWT'den alıyoruz
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out var userId))
            {
                return Unauthorized(new { message = "Geçersiz kullanıcı oturumu." });
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound(new { message = "Kullanıcı bulunamadı." });
            }

            // Klasörün var olduğundan emin olalım
            var uploadsFolder = Path.Combine(_environment.ContentRootPath, "uploads", "profile-images");
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            // Benzersiz dosya adı oluşturup kaydedelim
            var fileName = $"{userId}_{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(uploadsFolder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Kaydedilen görselin URL'ini oluşturalım
            var scheme = Request.Scheme;
            // Sunucu arkasında reverse proxy (nginx vb.) varsa HTTPS/port durumlarını doğru almak için
            if (Request.Headers.TryGetValue("X-Forwarded-Proto", out var proto))
            {
                scheme = proto.ToString();
            }

            var host = Request.Host.Value;
            if (Request.Headers.TryGetValue("X-Forwarded-Host", out var forwardedHost))
            {
                host = forwardedHost.ToString();
            }

            var fileUrl = $"{scheme}://{host}/uploads/profile-images/{fileName}";

            // Kullanıcı modelini güncelleyip veritabanına kaydedelim
            user.UpdateProfileImageUrl(fileUrl);
            await _context.SaveChangesAsync();

            return Ok(new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FullName = user.FullName,
                ProfileImageUrl = user.ProfileImageUrl
            });
        }
    }
}
