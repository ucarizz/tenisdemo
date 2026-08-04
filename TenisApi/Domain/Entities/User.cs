using System;

namespace TenisApi.Domain.Entities
{
    public class User
    {
        public int Id { get; private set; }
        public string Email { get; private set; }
        public string PasswordHash { get; private set; }
        public string FullName { get; private set; }
        public DateTime CreateDate { get; private set; }
        public string? ProfileImageUrl { get; private set; }

        #pragma warning disable CS8618 // EF Core için gerekli boş kurucu metot
        private User() { }
        #pragma warning restore CS8618

        public User(string email, string passwordHash, string fullName)
        {
            if (string.IsNullOrWhiteSpace(email))
                throw new ArgumentException("E-posta adresi boş olamaz.", nameof(email));
            if (string.IsNullOrWhiteSpace(passwordHash))
                throw new ArgumentException("Şifre hash'i boş olamaz.", nameof(passwordHash));
            if (string.IsNullOrWhiteSpace(fullName))
                throw new ArgumentException("Ad soyad boş olamaz.", nameof(fullName));

            Email = email.ToLowerInvariant().Trim();
            PasswordHash = passwordHash;
            FullName = fullName.Trim();
            CreateDate = DateTime.UtcNow;
        }

        public void UpdateProfile(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                throw new ArgumentException("Ad soyad boş olamaz.", nameof(fullName));

            FullName = fullName.Trim();
        }

        public void UpdateProfileImageUrl(string? profileImageUrl)
        {
            ProfileImageUrl = profileImageUrl;
        }
    }
}
