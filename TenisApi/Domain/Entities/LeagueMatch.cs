using System;
using System.Collections.Generic;

namespace TenisApi.Domain.Entities
{
    public class LeagueMatch
    {
        public int Id { get; private set; }
        public string Player1Name { get; private set; }
        public string Player2Name { get; private set; }
        public string MatchDate { get; private set; }
        public string? Score { get; private set; }
        public bool IsCompleted { get; private set; }
        public DateTime CreateDate { get; private set; }
        public bool IsDouble { get; private set; }
        public string? Player1PartnerName { get; private set; }
        public string? Player2PartnerName { get; private set; }
        public int? HostUserId { get; private set; }
        public int? GuestUserId { get; private set; }

        // Bire çok ilişki için veri havuzu (Domain Collection)
        private readonly List<MatchPointHistory> _pointHistories = new();
        public IReadOnlyCollection<MatchPointHistory> PointHistories => _pointHistories.AsReadOnly();

        // EF Core için gerekli boş kurucu metot
        #pragma warning disable CS8618 
        private LeagueMatch() { }
        #pragma warning restore CS8618

        public LeagueMatch(
            string player1Name, 
            string player2Name, 
            string matchDate, 
            bool isDouble = false, 
            string? player1PartnerName = null, 
            string? player2PartnerName = null,
            int? hostUserId = null,
            int? guestUserId = null)
        {
            if (string.IsNullOrWhiteSpace(player1Name))
                throw new ArgumentException("Oyuncu 1 adı boş olamaz.", nameof(player1Name));
            if (string.IsNullOrWhiteSpace(player2Name))
                throw new ArgumentException("Oyuncu 2 adı boş olamaz.", nameof(player2Name));
            if (string.IsNullOrWhiteSpace(matchDate))
                throw new ArgumentException("Maç tarihi boş olamaz.", nameof(matchDate));

            Player1Name = player1Name;
            Player2Name = player2Name;
            MatchDate = matchDate;
            IsCompleted = false;
            Score = null;
            CreateDate = DateTime.UtcNow;
            IsDouble = isDouble;
            Player1PartnerName = player1PartnerName;
            Player2PartnerName = player2PartnerName;
            HostUserId = hostUserId;
            GuestUserId = guestUserId;
        }

        // Maçı tamamlama iş kuralı (Domain Behavior)
        public void CompleteMatch(string score, IEnumerable<MatchPointHistory> pointHistories)
        {
            if (string.IsNullOrWhiteSpace(score))
                throw new ArgumentException("Tamamlanan bir maçın skoru girilmelidir.", nameof(score));

            Score = score;
            IsCompleted = true;

            _pointHistories.Clear();
            if (pointHistories != null)
            {
                _pointHistories.AddRange(pointHistories);
            }
        }

        // Maç tarihini güncelleme iş kuralı (Domain Behavior)
        public void RescheduleMatch(string newDate)
        {
            if (string.IsNullOrWhiteSpace(newDate))
                throw new ArgumentException("Yeni maç tarihi boş olamaz.", nameof(newDate));
            
            if (IsCompleted)
                throw new InvalidOperationException("Tamamlanmış bir maçın tarihi değiştirilemez.");

            MatchDate = newDate;
        }
    }
}
