import Foundation

enum AppConfigEndpoint: APIEndpoint {
    case versionCheck(platform: String, version: String)
    
    var path: String {
        switch self {
        case .versionCheck:
            return "app-config/version-check"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .versionCheck:
            return .get
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .versionCheck(let platform, let version):
            return [
                URLQueryItem(name: "platform", value: platform),
                URLQueryItem(name: "version", value: version)
            ]
        }
    }
}
