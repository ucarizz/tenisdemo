using System.Threading.Tasks;
using TenisApi.Application.DTOs;

namespace TenisApi.Application.Services
{
    public interface IAuthService
    {
        Task<AuthResponse> RegisterAsync(RegisterRequest request);
        Task<AuthResponse> LoginAsync(LoginRequest request);
    }
}
