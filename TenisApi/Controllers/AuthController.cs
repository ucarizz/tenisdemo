using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using TenisApi.Application.DTOs;
using TenisApi.Application.Services;

namespace TenisApi.Controllers
{
    [ApiController]
    [Route("v1/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
        {
            try
            {
                var response = await _authService.RegisterAsync(request);
                return Ok(response);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("login")]
        public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
        {
            try
            {
                var response = await _authService.LoginAsync(request);
                return Ok(response);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        [HttpPost("otp/send")]
        public async Task<ActionResult> SendOtp([FromBody] SendOtpRequest request)
        {
            try
            {
                await _authService.SendOtpAsync(request);
                return Ok(new { message = "Doğrulama kodu e-posta adresinize gönderildi." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("otp/verify")]
        public async Task<ActionResult<VerifyOtpResponse>> VerifyOtp([FromBody] VerifyOtpRequest request)
        {
            try
            {
                var response = await _authService.VerifyOtpAsync(request);
                return Ok(response);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
