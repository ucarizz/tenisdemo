using System.Text;

namespace TenisApi.Infrastructure.Middlewares
{
    public class RequestResponseLoggingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<RequestResponseLoggingMiddleware> _logger;

        public RequestResponseLoggingMiddleware(RequestDelegate next, ILogger<RequestResponseLoggingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // 1. Request Body Okuma (Model bağlamayı bozmamak için EnableBuffering kullanıyoruz)
            var requestBody = string.Empty;
            context.Request.EnableBuffering();
            
            if (context.Request.ContentLength > 0)
            {
                using (var reader = new StreamReader(
                    context.Request.Body,
                    encoding: Encoding.UTF8,
                    detectEncodingFromByteOrderMarks: false,
                    leaveOpen: true))
                {
                    requestBody = await reader.ReadToEndAsync();
                    context.Request.Body.Position = 0; // Akış konumunu sıfırlıyoruz ki Controller okuyabilsin
                }
            }

            // 2. Response Body Yakalama
            var originalResponseBodyStream = context.Response.Body;
            using (var responseBodyMemoryStream = new MemoryStream())
            {
                context.Response.Body = responseBodyMemoryStream;

                // Pipeline'daki diğer işlemleri (Controller vb.) çalıştır
                await _next(context);

                // Response verisini bellekten oku
                responseBodyMemoryStream.Position = 0;
                var responseBody = await new StreamReader(responseBodyMemoryStream).ReadToEndAsync();
                responseBodyMemoryStream.Position = 0;

                // Graylog'da JSON olarak aratılabilmesi için Structured logging yapıyoruz
                _logger.LogInformation(
                    "API Transaction: {Method} {Path} responded {StatusCode}. RequestBody: {RequestBody} ResponseBody: {ResponseBody}",
                    context.Request.Method,
                    context.Request.Path,
                    context.Response.StatusCode,
                    string.IsNullOrWhiteSpace(requestBody) ? null : requestBody,
                    string.IsNullOrWhiteSpace(responseBody) ? null : responseBody
                );

                // Gerçek response akışına verileri geri kopyala ki istemci yanıtı alabilsin
                await responseBodyMemoryStream.CopyToAsync(originalResponseBodyStream);
            }
        }
    }
}
