using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using TenisApi.Application.DTOs;
using TenisApi.Application.Services;

namespace TenisApi.Hubs
{
    public class TennisHub : Hub
    {
        private readonly LobbyManager _lobbyManager;
        private readonly ILeagueService _leagueService;

        public TennisHub(LobbyManager lobbyManager, ILeagueService leagueService)
        {
            _lobbyManager = lobbyManager;
            _leagueService = leagueService;
        }

        // Yeni bir lobi kurar ve kurucu istemciyi SignalR odasına ekler
        public async Task CreateLobby(string hostName, bool isDouble, string? hostPartnerName, string? hostProfileImageUrl)
        {
            var lobby = _lobbyManager.CreateLobby(hostName, isDouble, hostPartnerName, hostProfileImageUrl, Context.ConnectionId);
            _lobbyManager.AssociateConnection(Context.ConnectionId, lobby.Code);
            await Groups.AddToGroupAsync(Context.ConnectionId, lobby.Code);
            await Clients.Caller.SendAsync("LobbyCreated", lobby);
        }

        // Kod ile eşleşen lobi odasına katılır ve gruptaki herkese haber verir
        public async Task JoinLobby(string code, string guestName, string? guestPartnerName, string? guestProfileImageUrl)
        {
            code = code.ToUpperInvariant().Trim();
            var lobby = _lobbyManager.JoinLobby(code, guestName, guestPartnerName, guestProfileImageUrl, Context.ConnectionId);
            
            if (lobby == null)
            {
                await Clients.Caller.SendAsync("Error", "Lobi bulunamadı.");
                return;
            }

            _lobbyManager.AssociateConnection(Context.ConnectionId, code);
            await Groups.AddToGroupAsync(Context.ConnectionId, code);
            await Clients.Group(code).SendAsync("LobbyUpdated", lobby);
        }

        // Belirli veya ilk boş slota oyuncu olarak katılır (4 kişilik lobi / SharePlay desteği)
        public async Task JoinLobbySlot(string code, string name, string? profileImageUrl, int requestedSlotIndex = -1)
        {
            code = code.ToUpperInvariant().Trim();
            var lobby = _lobbyManager.JoinLobbySlot(code, name, profileImageUrl, Context.ConnectionId, requestedSlotIndex >= 0 ? requestedSlotIndex : null);

            if (lobby == null)
            {
                await Clients.Caller.SendAsync("Error", "Lobi bulunamadı veya tüm slotlar dolu.");
                return;
            }

            _lobbyManager.AssociateConnection(Context.ConnectionId, code);
            await Groups.AddToGroupAsync(Context.ConnectionId, code);
            await Clients.Group(code).SendAsync("LobbyUpdated", lobby);
        }

        // Oyuncunun lobideki slotunu / takımını değiştirir
        public async Task SwitchSlot(string code, int targetSlotIndex)
        {
            code = code.ToUpperInvariant().Trim();
            var lobby = _lobbyManager.SwitchSlot(code, Context.ConnectionId, targetSlotIndex);
            if (lobby != null)
            {
                await Clients.Group(code).SendAsync("LobbyUpdated", lobby);
            }
        }

        // Oyun ayarlarını odadaki tüm kullanıcılara eşitler
        public async Task UpdateSettings(string code, LobbySettingsDto settings)
        {
            code = code.ToUpperInvariant().Trim();
            var lobby = _lobbyManager.UpdateSettings(code, settings);
            if (lobby != null)
            {
                await Clients.Group(code).SendAsync("LobbySettingsUpdated", settings);
            }
        }

        private static readonly Random _random = new();

        // Kura aşamasını başlatır
        public async Task StartToss(string code)
        {
            code = code.ToUpperInvariant().Trim();
            await Clients.Group(code).SendAsync("TossStarted");
        }

        // Raketi çevirir ve sonucu odadaki herkese eşitler
        public async Task SpinRacket(string code)
        {
            code = code.ToUpperInvariant().Trim();
            var lobby = _lobbyManager.GetLobby(code);
            if (lobby != null)
            {
                bool isUp = _random.Next(2) == 0;
                string result = isUp ? "UP" : "DOWN"; // DÜZ veya TERS
                int winnerSlot = isUp ? 0 : 2;
                string winnerName = isUp ? lobby.HostName : (lobby.GuestName ?? "RAKİP");

                await Clients.Group(code).SendAsync("RacketSpun", result, winnerSlot, winnerName);
            }
        }

        // Kura kazananının servis tercihini uygular ve maçı başlatır
        public async Task SelectTossChoice(string code, string startingServer)
        {
            code = code.ToUpperInvariant().Trim();
            await Clients.Group(code).SendAsync("TossChoiceSelected", startingServer);
            await StartMatch(code);
        }

        // Maçı başlatır ve iki tarafın da ekranını geçirir
        public async Task StartMatch(string code)
        {
            code = code.ToUpperInvariant().Trim();
            var lobby = _lobbyManager.GetLobby(code);
            if (lobby != null)
            {
                // Create database record
                var dateString = DateTime.Now.ToString("dd.MM.yyyy - HH:mm");
                var match = await _leagueService.CreateMatchAsync(
                    lobby.HostName,
                    lobby.GuestName ?? "RAKİP",
                    dateString,
                    lobby.IsDouble,
                    lobby.HostPartnerName,
                    lobby.GuestPartnerName);
                
                // Store matchId in lobby DTO
                lobby.MatchId = match.Id;
                
                // Mark match started in manager
                _lobbyManager.StartMatch(code);
                
                await Clients.Group(code).SendAsync("MatchStarted", match.Id);
            }
        }

        // Canlı skor verilerini gruptaki diğer kullanıcıya yansıtır ve veri tabanını günceller
        public async Task SendScoreUpdate(string code, LiveMatchStateDto scoreState)
        {
            code = code.ToUpperInvariant().Trim();
            
            // Veri tabanını güncelle
            var lobby = _lobbyManager.GetLobby(code);
            if (lobby != null && lobby.MatchId.HasValue)
            {
                // Current score formatting (e.g. "6-4, 4-6")
                var setScoresList = new List<string>();
                foreach (var s in scoreState.SetScores)
                {
                    setScoresList.Add($"{s.P1Games}-{s.P2Games}");
                }
                var currentScore = string.Join(", ", setScoresList);
                if (string.IsNullOrWhiteSpace(currentScore))
                {
                    currentScore = $"{scoreState.P1Games}-{scoreState.P2Games}";
                }
                
                // If match is over, we also update it
                await _leagueService.UpdateMatchLiveStateAsync(
                    lobby.MatchId.Value,
                    currentScore,
                    scoreState.History,
                    scoreState.IsMatchOver);
            }

            await Clients.OthersInGroup(code).SendAsync("ScoreUpdated", scoreState);
        }

        // Lobiden veya maçtan güvenli şekilde ayrılır
        public async Task LeaveLobby(string code)
        {
            code = code.ToUpperInvariant().Trim();
            var (_, remainingLobby, leftPlayerName, _) = _lobbyManager.RemovePlayerByConnection(Context.ConnectionId, code);
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, code);
            await HandlePlayerDeparture(code, remainingLobby, leftPlayerName);
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var (code, remainingLobby, leftPlayerName, _) = _lobbyManager.RemovePlayerByConnection(Context.ConnectionId);
            if (!string.IsNullOrEmpty(code))
            {
                await HandlePlayerDeparture(code, remainingLobby, leftPlayerName);
            }
            await base.OnDisconnectedAsync(exception);
        }

        private async Task HandlePlayerDeparture(string code, LobbyStateDto? remainingLobby, string? leftPlayerName)
        {
            string departureName = string.IsNullOrEmpty(leftPlayerName) ? "Bir oyuncu" : leftPlayerName;

            if (remainingLobby != null)
            {
                // Eğer maç devam ediyorsa:
                if (remainingLobby.IsMatchStarted)
                {
                    bool opponentRemains = remainingLobby.Players.Any(p => p.Team == 2);
                    bool hostTeamRemains = remainingLobby.Players.Any(p => p.Team == 1);

                    // Eğer bir takım tamamen boşaldıysa maç devam edemez
                    if (!opponentRemains || !hostTeamRemains)
                    {
                        _lobbyManager.RemoveLobby(code);
                        await Clients.Group(code).SendAsync("PlayerLeft", $"{departureName} maçtan ayrıldı. Maç sonlandırıldı.");
                        return;
                    }
                    else
                    {
                        // Çiftler maçında 1 oyuncu ayrıldı ancak maçtaki diğer oyuncular devam ediyor
                        await Clients.Group(code).SendAsync("LobbyUpdated", remainingLobby);
                        await Clients.Group(code).SendAsync("PlayerLeftSlot", departureName);
                        await Clients.Group(code).SendAsync("PlayerLeftMatch", departureName);
                    }
                }
                else
                {
                    // Henüz lobi aşamasında biri ayrıldı
                    await Clients.Group(code).SendAsync("LobbyUpdated", remainingLobby);
                    await Clients.Group(code).SendAsync("PlayerLeftSlot", departureName);
                }
            }
            else
            {
                // Kurucu ayrıldı veya tüm lobi kapandı
                await Clients.OthersInGroup(code).SendAsync("PlayerLeft", $"{departureName} ayrıldı. Maç sonlandırıldı.");
            }
        }
    }
}
