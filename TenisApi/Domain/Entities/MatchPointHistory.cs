using System;

namespace TenisApi.Domain.Entities
{
    public class MatchPointHistory
    {
        public int Id { get; private set; }
        public int MatchId { get; private set; }
        
        public int P1Points { get; private set; }
        public int P2Points { get; private set; }
        
        public int P1Games { get; private set; }
        public int P2Games { get; private set; }
        
        public int P1Sets { get; private set; }
        public int P2Sets { get; private set; }
        
        public string Server { get; private set; } // "SİZ" veya "RAKİP"
        public int SequenceNumber { get; private set; } // Sıralama index'i

        // EF Core için gerekli boş kurucu metot
        #pragma warning disable CS8618
        private MatchPointHistory() { }
        #pragma warning restore CS8618

        public MatchPointHistory(
            int p1Points, 
            int p2Points, 
            int p1Games, 
            int p2Games, 
            int p1Sets, 
            int p2Sets, 
            string server, 
            int sequenceNumber)
        {
            if (p1Points < 0 || p2Points < 0 || p1Games < 0 || p2Games < 0 || p1Sets < 0 || p2Sets < 0)
                throw new ArgumentException("Skor değerleri negatif olamaz.");
            if (string.IsNullOrWhiteSpace(server))
                throw new ArgumentException("Servis atan oyuncu boş geçilemez.", nameof(server));
            if (sequenceNumber < 0)
                throw new ArgumentException("Sıra numarası negatif olamaz.", nameof(sequenceNumber));

            P1Points = p1Points;
            P2Points = p2Points;
            P1Games = p1Games;
            P2Games = p2Games;
            P1Sets = p1Sets;
            P2Sets = p2Sets;
            Server = server;
            SequenceNumber = sequenceNumber;
        }
    }
}
