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
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

enum AuthEndpoint: APIEndpoint {
    case register(RegisterRequest)
    case login(LoginRequest)
    
    var path: String {
        switch self {
        case .register:
            return "auth/register"
        case .login:
            return "auth/login"
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
        }
    }
}
