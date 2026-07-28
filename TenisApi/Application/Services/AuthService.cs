using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using TenisApi.Application.DTOs;
using TenisApi.Domain.Entities;
using TenisApi.Infrastructure.Persistence;

namespace TenisApi.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly TenisDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthService(TenisDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
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
            var user = new User(normalizedEmail, passwordHash, request.FullName);

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
                    FullName = user.FullName
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
                    FullName = user.FullName
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
    }
}
