using System.Threading.Tasks;

namespace TenisApi.Application.Services
{
    public interface IEmailService
    {
        Task SendEmailAsync(string toEmail, string subject, string body);
    }
}
