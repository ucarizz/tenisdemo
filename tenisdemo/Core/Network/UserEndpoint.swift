import Foundation

enum UserEndpoint: APIEndpoint {
    case uploadProfileImage(Data)
    
    var path: String {
        switch self {
        case .uploadProfileImage:
            return "users/profile-image"
        }
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var headers: [String: String]? {
        switch self {
        case .uploadProfileImage:
            let boundary = "Boundary-ProfileImageUpload"
            return [
                "Content-Type": "multipart/form-data; boundary=\(boundary)",
                "Accept": "application/json"
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .uploadProfileImage(let imageData):
            let boundary = "Boundary-ProfileImageUpload"
            var data = Data()
            
            // Multipart form-data wrapper
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            return data
        }
    }
}
