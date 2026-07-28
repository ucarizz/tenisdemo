using System;
using System.Security.Cryptography;

namespace TenisApi.Domain.Entities
{
    public static class PasswordHasher
    {
        private const int SaltSize = 16; // 128 bit
        private const int KeySize = 32;  // 256 bit
        private const int Iterations = 10000;
        private static readonly HashAlgorithmName HashAlgorithm = HashAlgorithmName.SHA256;

        // Şifreyi güvenli PBKDF2 algoritması kullanarak hash'ler
        public static string HashPassword(string password)
        {
            byte[] salt = RandomNumberGenerator.GetBytes(SaltSize);
            byte[] hash = Rfc2898DeriveBytes.Pbkdf2(
                password,
                salt,
                Iterations,
                HashAlgorithm,
                KeySize);

            // Kolay saklama için format: iteration.salt.hash
            return $"{Iterations}.{Convert.ToHexString(salt)}.{Convert.ToHexString(hash)}";
        }

        // Girilen şifrenin hash'lenmiş şifre ile eşleşip eşleşmediğini doğrular
        public static bool VerifyPassword(string password, string hashedPassword)
        {
            try
            {
                string[] parts = hashedPassword.Split('.', 3);
                if (parts.Length != 3)
                    return false;

                int iterations = int.Parse(parts[0]);
                byte[] salt = Convert.FromHexString(parts[1]);
                byte[] hash = Convert.FromHexString(parts[2]);

                byte[] inputHash = Rfc2898DeriveBytes.Pbkdf2(
                    password,
                    salt,
                    iterations,
                    HashAlgorithm,
                    hash.Length);

                // Zamanlama saldırılarını (timing attack) önlemek için sabit süreli karşılaştırma yapılır
                return CryptographicOperations.FixedTimeEquals(hash, inputHash);
            }
            catch
            {
                return false;
            }
        }
    }
}
