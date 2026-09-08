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

        // Lobiden güvenli şekilde ayrılır
        public async Task LeaveLobby(string code)
        {
            code = code.ToUpperInvariant().Trim();
            var (_, remainingLobby, leftPlayerName, _) = _lobbyManager.RemovePlayerByConnection(Context.ConnectionId, code);
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, code);
            
            if (remainingLobby != null)
            {
                await Clients.Group(code).SendAsync("LobbyUpdated", remainingLobby);
                if (!string.IsNullOrEmpty(leftPlayerName))
                {
                    await Clients.Group(code).SendAsync("PlayerLeftSlot", leftPlayerName);
                }
            }
            else
            {
                await Clients.OthersInGroup(code).SendAsync("PlayerLeft");
            }
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var (code, remainingLobby, leftPlayerName, _) = _lobbyManager.RemovePlayerByConnection(Context.ConnectionId);
            if (!string.IsNullOrEmpty(code))
            {
                if (remainingLobby != null)
                {
                    await Clients.Group(code).SendAsync("LobbyUpdated", remainingLobby);
                    if (!string.IsNullOrEmpty(leftPlayerName))
                    {
                        await Clients.Group(code).SendAsync("PlayerLeftSlot", leftPlayerName);
                    }
                }
                else
                {
                    await Clients.OthersInGroup(code).SendAsync("PlayerLeft");
                }
            }
            await base.OnDisconnectedAsync(exception);
        }
    }
}
