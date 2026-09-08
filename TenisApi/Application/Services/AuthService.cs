using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.Linq;
using TenisApi.Application.DTOs;
using TenisApi.Domain.Entities;
using TenisApi.Infrastructure.Persistence;

namespace TenisApi.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly TenisDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly IEmailService _emailService;

        public AuthService(TenisDbContext context, IConfiguration configuration, IEmailService emailService)
        {
            _context = context;
            _configuration = configuration;
            _emailService = emailService;
        }

        // Yeni kullanıcı kaydeder ve JWT döner
        public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
        {
            var normalizedEmail = request.Email.ToLowerInvariant().Trim();
            if (await _context.Users.AnyAsync(u => u.Email == normalizedEmail))
            {
                throw new ArgumentException("Bu e-posta adresiyle kayıtlı bir kullanıcı zaten var.");
            }

            var passwordHash = PasswordHasher.HashPassword(request.Password);
            var user = new User(normalizedEmail, passwordHash, request.FullName, request.IsKvkkAccepted);

            await _context.Users.AddAsync(user);
            await _context.SaveChangesAsync();

            var token = GenerateJwtToken(user);

            return new AuthResponse
            {
                Token = token,
                User = new UserDto
                {
                    Id = user.Id,
                    Email = user.Email,
                    FullName = user.FullName,
                    ProfileImageUrl = user.ProfileImageUrl
                }
            };
        }

        // Kullanıcı girişini doğrular ve JWT döner
        public async Task<AuthResponse> LoginAsync(LoginRequest request)
        {
            var normalizedEmail = request.Email.ToLowerInvariant().Trim();
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == normalizedEmail);

            if (user == null || !PasswordHasher.VerifyPassword(request.Password, user.PasswordHash))
            {
                throw new UnauthorizedAccessException("E-posta adresi veya şifre hatalı.");
            }

            var token = GenerateJwtToken(user);

            return new AuthResponse
            {
                Token = token,
                User = new UserDto
                {
                    Id = user.Id,
                    Email = user.Email,
                    FullName = user.FullName,
                    ProfileImageUrl = user.ProfileImageUrl
                }
            };
        }

        // JWT (JSON Web Token) Oluşturma metodu
        private string GenerateJwtToken(User user)
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var keyStr = jwtSettings.GetValue<string>("Key") ?? "DefaultTennisSuperSecretSecureKey1234567890!";
            var key = Encoding.UTF8.GetBytes(keyStr);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(ClaimTypes.Name, user.FullName),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var credentials = new SigningCredentials(
                new SymmetricSecurityKey(key),
                SecurityAlgorithms.HmacSha256Signature);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddDays(30), // Token 30 gün geçerli olsun
                SigningCredentials = credentials,
                Issuer = jwtSettings.GetValue<string>("Issuer") ?? "TenisApi",
                Audience = jwtSettings.GetValue<string>("Audience") ?? "tenisdemo"
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);

            return tokenHandler.WriteToken(token);
        }

        // E-posta adresine OTP kodu gönderir
        public async Task SendOtpAsync(SendOtpRequest request)
        {
            var normalizedEmail = request.Email.ToLowerInvariant().Trim();
            
            // Eski kullanılmamış aktif kodları geçersiz kılalım
            var activeCodes = await _context.OtpCodes
                .Where(o => o.Email == normalizedEmail && !o.IsUsed && o.ExpiresAt > DateTime.UtcNow)
                .ToListAsync();

            foreach (var activeCode in activeCodes)
            {
                activeCode.MarkAsUsed();
            }

            // 6 haneli rastgele kod üretelim
            var code = Random.Shared.Next(100000, 999999).ToString();
            var otp = new OtpCode(normalizedEmail, code);

            await _context.OtpCodes.AddAsync(otp);
            await _context.SaveChangesAsync();

            // E-posta gönderimi
            var subject = "CourtMate Giriş Kodu";
            var body = $@"
                <div style='font-family: Arial, sans-serif; padding: 20px; color: #333;'>
                    <h2 style='color: #8be01a;'>CourtMate Giriş</h2>
                    <p>Uygulamaya giriş yapmak veya kayıt olmak için kullanabileceğiniz 6 haneli doğrulama kodunuz:</p>
                    <div style='font-size: 24px; font-weight: bold; background-color: #f4f4f4; padding: 15px; border-radius: 8px; display: inline-block; letter-spacing: 2px; margin: 10px 0;'>
                        {code}
                    </div>
                    <p style='font-size: 12px; color: #888; margin-top: 20px;'>Bu kod 15 dakika boyunca geçerlidir. Eğer bu isteği siz yapmadıysanız bu e-postayı görmezden gelebilirsiniz.</p>
                </div>";

            await _emailService.SendEmailAsync(normalizedEmail, subject, body);
        }

        // OTP kodunu doğrular ve giriş/kayıt durumunu döner
        public async Task<VerifyOtpResponse> VerifyOtpAsync(VerifyOtpRequest request)
        {
            var normalizedEmail = request.Email.ToLowerInvariant().Trim();
            
            var otp = await _context.OtpCodes
                .Where(o => o.Email == normalizedEmail && !o.IsUsed)
                .OrderByDescending(o => o.CreatedAt)
                .FirstOrDefaultAsync();

            if (otp == null || otp.Code != request.Code.Trim() || otp.ExpiresAt < DateTime.UtcNow)
            {
                throw new UnauthorizedAccessException("Girdiğiniz doğrulama kodu geçersiz veya süresi dolmuş.");
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == normalizedEmail);

            if (user == null)
            {
                // Kullanıcı bulunamadı, kayıt olmalı
                if (string.IsNullOrWhiteSpace(request.FullName))
                {
                    // Kod doğru ama kayıt tamamlanmadı, bu yüzden henüz "IsUsed" yapmıyoruz.
                    return new VerifyOtpResponse
                    {
                        RequiresFullName = true,
                        Token = null,
                        User = null
                    };
                }

                // İsim gönderilmişse yeni kullanıcıyı kaydet
                // Şifre yerine rastgele güvenli bir GUID şifresi atıyoruz
                var randomPassword = Guid.NewGuid().ToString();
                var passwordHash = PasswordHasher.HashPassword(randomPassword);
                user = new User(normalizedEmail, passwordHash, request.FullName);

                await _context.Users.AddAsync(user);
            }

            // Kodu sadece giriş/kayıt başarıyla tamamlandığında kullanıldı olarak işaretle
            otp.MarkAsUsed();
            await _context.SaveChangesAsync();

            // JWT token üret
            var token = GenerateJwtToken(user);

            return new VerifyOtpResponse
            {
                RequiresFullName = false,
                Token = token,
                User = new UserDto
                {
                    Id = user.Id,
                    Email = user.Email,
                    FullName = user.FullName,
                    ProfileImageUrl = user.ProfileImageUrl
                }
            };
        }
    }
}
