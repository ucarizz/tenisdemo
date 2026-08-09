import Foundation

struct AuthUser: Codable {
    let id: Int
    let email: String
    let fullName: String
    let profileImageUrl: String?
}

struct AuthResponse: Codable {
    let token: String
    let user: AuthUser
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let fullName: String
    let isKvkkAccepted: Bool
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct SendOtpRequest: Encodable {
    let email: String
}

struct VerifyOtpRequest: Encodable {
    let email: String
    let code: String
    let fullName: String?
}

struct VerifyOtpResponse: Decodable {
    let requiresFullName: Bool
    let token: String?
    let user: AuthUser?
}

enum AuthEndpoint: APIEndpoint {
    case register(RegisterRequest)
    case login(LoginRequest)
    case sendOtp(SendOtpRequest)
    case verifyOtp(VerifyOtpRequest)
    
    var path: String {
        switch self {
        case .register:
            return "auth/register"
        case .login:
            return "auth/login"
        case .sendOtp:
            return "auth/otp/send"
        case .verifyOtp:
            return "auth/otp/verify"
        }
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        switch self {
        case .register(let request):
            return try? encoder.encode(request)
        case .login(let request):
            return try? encoder.encode(request)
        case .sendOtp(let request):
            return try? encoder.encode(request)
        case .verifyOtp(let request):
            return try? encoder.encode(request)
        }
    }
}
