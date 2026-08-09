import Foundation

enum LegalEndpoint: APIEndpoint {
    case getKvkk
    
    var path: String {
        switch self {
        case .getKvkk:
            return "legal/kvkk"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getKvkk:
            return .get
        }
    }
    
    var body: Data? {
        return nil
    }
}
