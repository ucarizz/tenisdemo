using System;

namespace TenisApi.Domain.Entities
{
    public class OtpCode
    {
        public int Id { get; private set; }
        public string Email { get; private set; }
        public string Code { get; private set; }
        public DateTime CreatedAt { get; private set; }
        public DateTime ExpiresAt { get; private set; }
        public bool IsUsed { get; private set; }

        #pragma warning disable CS8618 // Required for EF Core
        private OtpCode() { }
        #pragma warning restore CS8618

        public OtpCode(string email, string code, int expiryMinutes = 15)
        {
            if (string.IsNullOrWhiteSpace(email))
                throw new ArgumentException("E-posta adresi boş olamaz.", nameof(email));
            if (string.IsNullOrWhiteSpace(code))
                throw new ArgumentException("Kod boş olamaz.", nameof(code));

            Email = email.ToLowerInvariant().Trim();
            Code = code.Trim();
            CreatedAt = DateTime.UtcNow;
            ExpiresAt = CreatedAt.AddMinutes(expiryMinutes);
            IsUsed = false;
        }

        public void MarkAsUsed()
        {
            IsUsed = true;
        }
    }
}
