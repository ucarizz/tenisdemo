using System.Net;
using System.Text.Json;

namespace TenisApi.Infrastructure.Middlewares
{
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionHandlingMiddleware> _logger;

        public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex);
            }
        }

        private async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            // Log with structured properties for easy querying in Graylog
            _logger.LogError(exception, 
                "An unhandled exception occurred during request {Method} {Path}. Client IP: {ClientIp}", 
                context.Request.Method, 
                context.Request.Path, 
                context.Connection.RemoteIpAddress?.ToString() ?? "Unknown");

            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

            var response = new
            {
                status_code = context.Response.StatusCode,
                message = "Sunucuda beklenmeyen bir hata oluştu.",
                detail = exception.Message // In production, you might want to hide this unless in Development mode
            };

            var jsonOptions = new JsonSerializerOptions 
            { 
                PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower 
            };

            await context.Response.WriteAsync(JsonSerializer.Serialize(response, jsonOptions));
        }
    }
}
