using System.Collections.Generic;
using System.Threading.Tasks;
using TenisApi.Domain.Entities;

namespace TenisApi.Domain.Repositories
{
    public interface ILeagueMatchRepository
    {
        Task<LeagueMatch?> GetByIdAsync(int id);
        Task<IEnumerable<LeagueMatch>> GetAllAsync();
        Task AddAsync(LeagueMatch match);
        Task UpdateAsync(LeagueMatch match);
        Task DeleteAsync(LeagueMatch match);
    }
}
